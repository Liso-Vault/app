import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/core/hive/hive_shared_vaults.service.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/drawer/drawer_widget.controller.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/shared_vaults/shared_vault.controller.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart' as minio;
import 'package:path/path.dart';
import 'package:supercharged/supercharged.dart';

import '../../core/hive/hive_items.service.dart';
import '../../core/hive/models/item.hive.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/liso/liso_paths.dart';
import '../../core/utils/globals.dart';
import '../wallet/wallet.service.dart';
import 'model/s3_content.model.dart';
import 'model/s3_folder_info.model.dart';

class S3Service extends GetxService with ConsoleMixin {
  static S3Service get to => Get.find();

  // VARIABLES
  Minio? client;
  bool ready = false;
  final config = Get.find<ConfigService>();
  final persistence = Get.find<Persistence>();
  List<S3Content> contentsCache = [];
  final syncTimeoutDuration = 20.seconds;

  // PROPERTIES
  final syncing = false.obs;
  final syncingSharedVaults = false.obs;
  final inSync = false.obs;
  final storageSize = 0.obs;
  final objectsCount = 0.obs;
  final downloadTotalSize = 0.obs;
  final downloadedSize = 0.obs;
  final uploadTotalSize = 0.obs;
  final uploadedSize = 0.obs;
  final progressValue = 0.05.obs;
  final progressText = 'Syncing...'.obs;

  // GETTERS
  S3Content get lisoContent => S3Content(path: vaultPath);

  String get rootPath => '${WalletService.to.longAddress}/';
  String get vaultPath => join(rootPath, kVaultFileName).replaceAll('\\', '/');
  String get backupsPath => join(rootPath, 'Backups').replaceAll('\\', '/');
  String get historyPath => join(rootPath, 'History').replaceAll('\\', '/');
  String get sharedPath => join(rootPath, 'Shared').replaceAll('\\', '/');
  String get sharedVaultsPath =>
      join(sharedPath, 'Vaults').replaceAll('\\', '/');

  String get filesPath => ('${join(
        rootPath,
        'Files',
        DrawerMenuController.to.filterGroupId.value.toString(),
      )}/')
          .replaceAll('\\', '/');

  // INIT

  // FUNCTIONS

  void init() {
    try {
      if (persistence.syncProvider.val == LisoSyncProvider.custom.name) {
        client = Minio(
          endPoint: persistence.s3Endpoint.val,
          accessKey: persistence.s3AccessKey.val,
          secretKey: persistence.s3SecretKey.val,
          port: int.tryParse(persistence.s3Port.val),
          region: persistence.s3Region.val.isEmpty
              ? null
              : persistence.s3Region.val,
          sessionToken: persistence.s3SessionToken.val.isEmpty
              ? null
              : persistence.s3SessionToken.val,
          enableTrace: persistence.s3EnableTrace.val,
          useSSL: persistence.s3UseSsl.val,
        );
      } else {
        client = Minio(
          endPoint: config.s3.endpoint,
          accessKey: config.s3.key,
          secretKey: config.s3.secret,
        );
      }

      ready = true;
      console.info('init');
    } catch (e, s) {
      console.error('Exception: $e, Stacktrace: $s');

      CrashlyticsService.to.record(FlutterErrorDetails(
        exception: e,
        stack: s,
      ));
    }
  }

  void _syncProgress(double value, String? message) {
    progressValue.value = value;
    if (message != null) progressText.value = message;
  }

  Future<Either<dynamic, bool>> sync() async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Right(false);

    if (syncing.value) {
      console.warning('already down syncing');
      return const Right(false);
    }

    console.info('syncing...');
    syncing.value = true;
    _syncProgress(0.1, 'Syncing...');
    final statResult = await stat(lisoContent)
        .timeout(syncTimeoutDuration, onTimeout: () => const Left('Timed Out'));

    if (statResult.isLeft) {
      if (statResult.left is MinioError &&
          statResult.left.message!.contains('Not Found')) {
        inSync.value = true;
        _syncProgress(0.5, 'Initializing...');
        final upsyncResult = await upSync().timeout(syncTimeoutDuration,
            onTimeout: () => const Left('Timed Out'));
        _syncProgress(1, '');
        syncing.value = false;

        return upsyncResult;
      }

      syncing.value = false;
      console.error('Stat Error: ${statResult.left}');
      return Left(statResult.left);
    }

    final serverMetadata = HiveMetadata.fromJson(
      jsonDecode(statResult.right.metaData!['client']!),
    );

    _syncProgress(0.2, 'Fetching...');
    final downResult = await _downSync()
        .timeout(syncTimeoutDuration, onTimeout: () => const Left('Timed Out'));
    if (downResult.isLeft) return Left(downResult.left);

    // we are now ready to upSync because we are not in sync with server
    inSync.value = true;
    Persistence.to.changes.val = 0;
    persistence.metadata.val = serverMetadata.toJsonString();

    // up sync local changes with server
    _syncProgress(0.5, 'Pushing...');
    await upSync();
    syncing.value = false;
    _syncProgress(1, '');
    MainScreenController.to.load();
    syncSharedVaults();
    return Right(downResult.right);
  }

  // DOWN SYNC
  Future<Either<dynamic, bool>> _downSync() async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Right(false);
    console.info('down syncing...');

    final downloadResult = await downloadFile(
      s3Path: vaultPath,
      filePath: LisoPaths.tempVaultFilePath,
    );

    if (downloadResult.isLeft) return Left(downloadResult.left);
    _syncProgress(0.3, null);
    final items =
        await HiveItemsService.to.parseVaultFile(downloadResult.right);
    _syncProgress(0.4, null);
    await _mergeItems(items);
    return const Right(true);
  }

  Future<void> _mergeItems(List<HiveLisoItem> serverItems) async {
    var localItems = HiveItemsService.to.box;
    // MERGED
    final mergedItems = {...serverItems, ...localItems.values};
    console.info('merged: ${mergedItems.length}');
    final leastUpdatedDuplicates = <HiveLisoItem>[];

    for (var x in mergedItems) {
      // skip if item already added to least updated item list
      if (leastUpdatedDuplicates
          .where((e) => e.identifier == x.identifier)
          .isNotEmpty) continue;
      // find duplicates
      final duplicate = mergedItems.where((y) => y.identifier == x.identifier);
      // return the least updated item in duplicate
      if (duplicate.length > 1) {
        final leastUpdatedItem = duplicate.first.metadata.updatedTime
                .isBefore(duplicate.last.metadata.updatedTime)
            ? duplicate.first
            : duplicate.last;
        leastUpdatedDuplicates.add(leastUpdatedItem);
      }
    }

    console.info('least updated duplicates: ${leastUpdatedDuplicates.length}');
    // remove duplicate + least updated item
    mergedItems.removeWhere(
      (e) => leastUpdatedDuplicates.contains(e),
    );

    // clear and reload updated items
    await localItems.clear();
    await localItems.addAll(mergedItems);
  }

  // UP SYNC
  Future<Either<dynamic, bool>> upSync() async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');
    if (!inSync.value) {
      return const Left('not in sync with server');
    }

    console.info('up syncing...');
    final backupResult = await backup(lisoContent);
    // ignore backup error and continue
    if (backupResult.isLeft) {
      console.warning('Failed to backup: ${backupResult.left}');
    } else {
      console.info(
        'success! eTag: ${backupResult.right.eTag}, lastModified: ${backupResult.right.lastModified}',
      );
    }

    final vaultFile = await HiveItemsService.to.export(
      path: LisoPaths.tempVaultFilePath,
    );

    // UPLOAD
    _syncProgress(0.7, null);
    final metadataString = await updatedLocalMetadata();

    final uploadResult = await uploadFile(
      vaultFile,
      s3Path: vaultPath,
      metadata: metadataString,
    );

    await vaultFile.delete(); // delete temp vault file
    persistence.metadata.val = metadataString;
    _syncProgress(0.9, null);
    if (uploadResult.isLeft) return Left(uploadResult.left);
    console.info('uploaded! eTag: ${uploadResult.right}');
    return const Right(true);
  }

  Future<Either<dynamic, String>> createBlankFile(String s3path) async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');

    console.warning('creating blank file: $s3path');
    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.s3.preferredBucket,
        s3path,
        Stream<Uint8List>.value(Uint8List(0)),
        onProgress: (size) => uploadedSize.value = size,
        metadata: {
          'client': await updatedLocalMetadata(),
          'version': kS3MetadataVersion,
        },
      );
    } catch (e) {
      return Left(e);
    }

    console.info('uploaded: $eTag');
    return Right(eTag);
  }

  Future<Either<dynamic, bool>> syncSharedVaults() async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');

    if (SharedVaultsController.to.data.isEmpty) {
      return const Left('nothing to sync');
    }

    if (syncingSharedVaults.value) {
      return const Left('still syncing shared vaults');
    }

    console.info(
      'syncing ${SharedVaultsController.to.data.length} shared vaults...',
    );

    final metadataString = await updatedLocalMetadata();

    for (final doc in SharedVaultsController.to.data) {
      final sharedVault = doc.data();

      final sharedItems = HiveItemsService.to.data
          .where((item) => item.sharedVaultIds.contains(sharedVault.docId))
          .toList();

      final sharedItemsJson =
          List<dynamic>.from(sharedItems.map((x) => x.toJson()));

      final sharedItemsJsonString = jsonEncode(sharedItemsJson);
      final bytes = Uint8List.fromList(sharedItemsJsonString.codeUnits);
      final sharedVaultResults =
          HiveSharedVaultsService.to.data.where((e) => e.id == doc.id);

      // just incase cipher key is not found
      if (sharedVaultResults.isEmpty) {
        UIUtils.showSimpleDialog(
          'Error Syncing Shared Vault',
          'Cannot find saved Cipher Key. Please report to the developer.',
        );

        return const Left('value');
      }

      final encryptedBytes = CipherService.to.encrypt(
        bytes,
        cipherKey: sharedVaultResults.first.cipherKey,
      );

      String eTag = '';
      final s3path = join(sharedPath, '${sharedVault.docId}.$kVaultExtension');
      console.warning('uploading: $s3path');

      try {
        eTag = await client!.putObject(
          config.s3.preferredBucket,
          s3path,
          Stream<Uint8List>.value(encryptedBytes),
          onProgress: (size) => uploadedSize.value = size,
          metadata: {'client': metadataString, 'version': kS3MetadataVersion},
        );
      } catch (e) {
        return Left(e);
      }

      console.info('uploaded: $eTag');
    }

    console.wtf('done');
    return const Right(true);
  }

  // currently doesn't work on Filebase
  Future<Either<dynamic, minio.CopyObjectResult>> backup(
      S3Content content) async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');
    console.info('backup: ${content.path}...');

    try {
      final result = await client!.copyObject(
        config.s3.preferredBucket,
        content.path,
        backupsPath,
        // CopyConditions(),
      );

      return Right(result);
    } catch (e) {
      return Left(e);
    }
  }

  Future<Either<dynamic, minio.StatObjectResult>> stat(
      S3Content content) async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');
    console.info(
      'stat: ${config.s3.preferredBucket}->${basename(content.path)}...',
    );

    try {
      final result = await client!.statObject(
        config.s3.preferredBucket,
        content.path,
      );

      return Right(result);
    } catch (e) {
      return Left(e);
    }
  }

  Future<Either<dynamic, bool>> remove(S3Content content) async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');
    console.info('removing: ${content.path}...');

    try {
      await client!.removeObject(
        config.s3.preferredBucket,
        content.path,
      );
    } catch (e) {
      return Left(e);
    }

    return const Right(true);
  }

  Future<Either<dynamic, List<S3Content>>> fetch({
    required String path,
    S3ContentType? filterType,
    List<String> filterExtensions = const [],
  }) async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');
    console.info('fetch: $path...');
    minio.ListObjectsResult? result;

    try {
      result = await client!.listAllObjectsV2(
        config.s3.preferredBucket,
        prefix: path,
      );
    } catch (e) {
      return Left(e);
    }

    console.info(
      'prefixes: ${result.prefixes.length}, objects: ${result.objects.length}',
    );

    // remove current directory
    result.objects.removeWhere(
      (e) => e.key == path || !e.key!.contains(rootPath),
    );

    List<S3Content> contents = [];
    // convert prefixes to content
    if (filterType == null || filterType == S3ContentType.directory) {
      contents.addAll(_prefixesToContents(result.prefixes));
    }

    // convert objects to content
    if (filterType == null || filterType == S3ContentType.file) {
      var filtered = result.objects;
      // filter by extension
      if (filterExtensions.isNotEmpty) {
        filtered = result.objects
            .where((e) => filterExtensions.contains(extension(e.key!)))
            .toList();
      }

      contents.addAll(_objectsToContents(filtered));
    }

    return Right(contents);
  }

  Future<Either<dynamic, S3FolderInfo>> folderInfo(String s3Path) async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');
    console.info('folder size: $s3Path...');
    minio.ListObjectsResult? result;

    try {
      result = await client!.listAllObjectsV2(
        config.s3.preferredBucket,
        prefix: s3Path,
        recursive: true,
      );
    } catch (e) {
      return Left(e);
    }

    console.info(
      'prefixes: ${result.prefixes.length}, objects: ${result.objects.length}',
    );

    int totalSize = 0;

    for (var e in result.objects) {
      totalSize += e.size!;
    }

    console.info('total size: $totalSize');

    return Right(S3FolderInfo(
      objects: result.objects,
      totalSize: totalSize,
    ));
  }

  Future<Either<dynamic, String>> getPreSignedUrl(String s3Path) async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');
    console.info('pre signing: $s3Path...');
    String? result;

    try {
      result = await client!.presignedGetObject(
        config.s3.preferredBucket,
        s3Path,
        expires: 1.hours.inSeconds,
      );
    } catch (e) {
      return Left(e);
    }

    console.info('presigned url: $result');
    return Right(result);
  }

  Future<Either<dynamic, File>> downloadFile({
    required String s3Path,
    required String filePath,
    bool force = false,
  }) async {
    if (!ready) init();
    if (!persistence.canSync && ready && !force) return const Left('offline');
    console
        .info('downloading: ${ConfigService.to.s3.preferredBucket} -> $s3Path');
    MinioByteStream? stream;

    try {
      stream =
          await client!.getObject(ConfigService.to.s3.preferredBucket, s3Path);
    } catch (e) {
      // CrashlyticsService.to.record(FlutterErrorDetails(
      //   exception: e,
      //   stack: s,
      // ));

      return Left(e);
    }

    console.info('download size: ${filesize(stream.contentLength)}');
    final file = File(filePath);
    await stream.pipe(file.openWrite());
    console.info('downloaded to: $filePath');
    return Right(file);
  }

  Future<Either<dynamic, String>> uploadFile(
    File file, {
    required String s3Path,
    required String metadata,
  }) async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');
    console.info('uploading...');
    uploadTotalSize.value = await file.length();
    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.s3.preferredBucket,
        s3Path,
        Stream<Uint8List>.value(file.readAsBytesSync()),
        onProgress: (size) => uploadedSize.value = size,
        metadata: {
          'client': metadata,
          'version': kS3MetadataVersion,
        },
      );
    } catch (e) {
      return Left(e);
    }

    // reset download indicators
    uploadTotalSize.value = 0;
    uploadedSize.value = 0;

    return Right(eTag);
  }

  Future<Either<dynamic, String>> createFolder(
    String name, {
    required String s3Path,
    required String metadata,
  }) async {
    if (!ready) init();
    if (!persistence.canSync && ready) return const Left('offline');
    console.info('creating folder...');
    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.s3.preferredBucket,
        join(s3Path, '$name/').replaceAll('\\', '/'),
        Stream<Uint8List>.value(Uint8List(0)),
        metadata: {
          'client': metadata,
          'version': kS3MetadataVersion,
        },
      );
    } catch (e) {
      return Left(e);
    }

    return Right(eTag);
  }

  Future<S3FolderInfo?> fetchStorageSize() async {
    final result = await folderInfo(S3Service.to.rootPath);

    if (result.isLeft) {
      console.error('fetchStorageSize: ${result.left}');
      return null;
    }

    final info = result.right;

    storageSize.value = info.totalSize;
    objectsCount.value = info.objects.length;

    // cache objects
    contentsCache = _objectsToContents(info.objects as List<minio.Object>);

    return info;
  }

  // UTILS

  List<S3Content> _objectsToContents(List<minio.Object> objects) {
    return objects
        .map(
          (e) => S3Content(
            name: basename(e.key!),
            path: e.key!,
            size: e.size!,
            object: e,
            type: extension(e.key!).isNotEmpty || e.size! > 0
                ? S3ContentType.file
                : S3ContentType.directory,
          ),
        )
        .toList();
  }

  List<S3Content> _prefixesToContents(List<String> prefixes) {
    return prefixes
        .map(
          (e) => S3Content(
            name: basename(e),
            path: e,
            type: S3ContentType.directory,
          ),
        )
        .toList();
  }

  HiveMetadata? _localMetadata() {
    if (persistence.metadata.val.isEmpty) return null;
    return HiveMetadata.fromJson(jsonDecode(persistence.metadata.val));
  }

  Future<String> updatedLocalMetadata() async {
    final metadata = _localMetadata() ?? await HiveMetadata.get();
    return (await metadata.getUpdated()).toJsonString();
  }
}
