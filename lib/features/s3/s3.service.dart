import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/features/drawer/drawer_widget.controller.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/hive/models/item.hive.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/services/wallet.service.dart';
import '../../core/utils/file.util.dart';
import '../../core/utils/globals.dart';
import 'model/s3_content.model.dart';
import 'model/s3_folder_info.model.dart';

class S3Service extends GetxService with ConsoleMixin {
  static S3Service get to => Get.find();

  // VARIABLES
  Minio? client;
  final config = Get.find<ConfigService>();
  final persistence = Get.find<PersistenceService>();

  // PROPERTIES
  final syncing = false.obs;
  final inSync = false.obs;
  final storageSize = 0.obs;
  final downloadTotalSize = 0.obs;
  final downloadedSize = 0.obs;
  final uploadTotalSize = 0.obs;
  final uploadedSize = 0.obs;
  final progressValue = 0.05.obs;
  final progressText = 'Syncing...'.obs;

  // GETTERS
  String get rootPath => '${WalletService.to.address}/';
  String get backupsPath => join(rootPath, 'Backups').replaceAll('\\', '/');
  String get historyPath => join(rootPath, 'History').replaceAll('\\', '/');

  String get filesPath => (join(
            rootPath,
            'Files',
            DrawerMenuController.to.filterGroupIndex.value.toString(),
          ) +
          '/')
      .replaceAll('\\', '/');

  S3Content get lisoContent => S3Content(path: vaultPath);

  String get vaultPath => join(
        WalletService.to.address,
        LisoManager.vaultFilename,
      ).replaceAll('\\', '/');

  // INIT

  // FUNCTIONS

  void init() {
    try {
      client = Minio(
        endPoint: config.s3.endpoint,
        accessKey: config.s3.key,
        secretKey: config.s3.secret,
      );

      console.info('init');
    } catch (e, s) {
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
    if (!persistence.canSync) return const Right(false);

    if (syncing.value) {
      console.warning('already down syncing');
      return const Right(false);
    }

    console.info('syncing...');
    syncing.value = true;
    _syncProgress(0.1, 'Syncing...');
    final statResult = await stat(lisoContent);

    if (statResult.isLeft) {
      if (statResult.left is MinioError &&
          statResult.left.message!.contains('Not Found')) {
        console.error('New cloud user: upsync current vault');
        inSync.value = true;
        _syncProgress(0.5, 'Initializing...');
        final upsyncResult = await upSync();
        _syncProgress(1, '');
        syncing.value = false;

        return Right(
          upsyncResult.isLeft ? upsyncResult.left : upsyncResult.right,
        );
      }

      syncing.value = false;
      console.error('Stat Error: ${statResult.left}');
      return Left(statResult.left);
    }

    final serverMetadata = HiveMetadata.fromJson(
      jsonDecode(statResult.right.metaData!['client']!),
    );

    _syncProgress(0.2, 'Fetching...');
    final downResult = await _downSync();
    if (downResult.isLeft) return Left(downResult.left);

    // we are now ready to upSync because we are not in sync with server
    inSync.value = true;
    PersistenceService.to.changes.val = 0;
    persistence.metadata.val = serverMetadata.toJsonString();

    // up sync local changes with server
    _syncProgress(0.5, 'Pushing...');
    await upSync();
    syncing.value = false;
    _syncProgress(1, '');
    MainScreenController.to.load();
    return Right(downResult.right);
  }

  // DOWN SYNC
  Future<Either<dynamic, bool>> _downSync() async {
    if (!persistence.canSync) return const Right(false);
    console.info('down syncing...');

    final downloadResult = await downloadFile(
      s3Path: vaultPath,
      filePath: LisoManager.tempVaultFilePath,
    );

    if (downloadResult.isLeft) return Left(downloadResult.left);
    _syncProgress(0.3, null);
    final vaultFile = downloadResult.right;
    final readResult = LisoManager.readArchive(vaultFile.path);
    FileUtils.delete(vaultFile.path); // delete temporary vault file
    if (readResult.isLeft) return Left(readResult.left);

    // extract boxes
    final extractResult = await LisoManager.extractArchive(
      readResult.right,
      path: LisoManager.tempPath,
      fileNamePrefix: 'temp_',
    );

    if (extractResult.isLeft) return Left(extractResult.left);
    await HiveManager.unwatchBoxes();
    _syncProgress(0.4, null);
    await _mergeItems();
    HiveManager.watchBoxes();
    return const Right(true);
  }

  Future<void> _mergeItems() async {
    var localItems = HiveManager.items!;

    final tempItems = await Hive.openBox<HiveLisoItem>(
      'temp_$kHiveBoxItems',
      encryptionCipher: HiveAesCipher(Globals.encryptionKey),
      path: LisoManager.tempPath,
    );

    if (tempItems.isEmpty) {
      await tempItems.clear();
      await tempItems.deleteFromDisk();
      return console.warning('temp items is empty');
    }

    console.warning('server items: ${tempItems.length}');
    console.warning('local items: ${localItems.length}');

    // MERGED
    final mergedItems = {...tempItems.values, ...localItems.values};
    console.info('merged: ${mergedItems.length}');
    final leastUpdatedDuplicates = <HiveLisoItem>[];

    for (var x in mergedItems) {
      // console.warning('${x.identifier} - ${x.metadata.updatedTime}');
      // skip if item already added to least updated item list
      if (leastUpdatedDuplicates
          .where((e) => e.identifier == x.identifier)
          .isNotEmpty) continue;
      // find duplicates
      final duplicate = mergedItems.where((y) => y.identifier == x.identifier);
      // return the least updated item in duplicate
      if (duplicate.length > 1) {
        final _leastUpdatedItem = duplicate.first.metadata.updatedTime
                .isBefore(duplicate.last.metadata.updatedTime)
            ? duplicate.first
            : duplicate.last;
        leastUpdatedDuplicates.add(_leastUpdatedItem);
      }
    }

    console.info('least updated duplicates: ${leastUpdatedDuplicates.length}');
    // remove duplicate + least updated item
    mergedItems.removeWhere(
      (e) => leastUpdatedDuplicates.contains(e),
    );

    // delete temp items
    await tempItems.clear();
    await tempItems.deleteFromDisk();
    // clear and reload updated items
    await localItems.clear();
    await localItems.addAll(mergedItems);
  }

  // UP SYNC
  Future<Either<dynamic, bool>> upSync() async {
    if (!persistence.canSync) return const Left('offline');
    if (!inSync.value) {
      return const Left('not in sync with server');
    }

    console.info('syncing...');
    final backupResult = await backup(lisoContent);
    // ignore backup error and continue
    if (backupResult.isLeft) {
      console.warning('Failed to backup: ${backupResult.left}');
    } else {
      console.info(
        'success! eTag: ${backupResult.right.eTag}, lastModified: ${backupResult.right.lastModified}',
      );
    }

    // temporarily close boxes to exclude hive .lock files
    await HiveManager.closeBoxes();
    final archiveResult = await LisoManager.createArchive(
      Directory(LisoManager.hivePath),
      filePath: LisoManager.tempVaultFilePath,
    );
    // reopen boxes
    await HiveManager.openBoxes();
    if (archiveResult.isLeft) return Left(archiveResult.left);
    // UPLOAD
    _syncProgress(0.7, null);
    final metadataString = await updatedLocalMetadata();

    final uploadResult = await uploadFile(
      archiveResult.right,
      s3Path: vaultPath,
      metadata: metadataString,
    );

    archiveResult.right.delete(); // delete temp vault file
    persistence.metadata.val = metadataString;
    _syncProgress(0.9, null);
    if (uploadResult.isLeft) return Left(uploadResult.left);
    console.info('uploaded! eTag: ${uploadResult.right}');
    return const Right(true);
  }

  // currently doesn't work on Filebase
  Future<Either<dynamic, CopyObjectResult>> backup(S3Content content) async {
    if (!persistence.canSync) return const Left('offline');
    console.info('backup: ${content.path}...');

    try {
      final result = await client!.copyObject(
        config.s3.bucket,
        content.path,
        backupsPath,
        // CopyConditions(),
      );

      return Right(result);
    } catch (e) {
      return Left(e);
    }
  }

  Future<Either<dynamic, StatObjectResult>> stat(S3Content content) async {
    if (!persistence.canSync) return const Left('offline');
    console.info('stat: ${basename(content.path)}...');

    try {
      final result = await client!.statObject(
        config.s3.bucket,
        content.path,
      );

      return Right(result);
    } catch (e) {
      return Left(e);
    }
  }

  Future<Either<dynamic, bool>> remove(S3Content content) async {
    if (!persistence.canSync) return const Left('offline');
    console.info('removing: ${content.path}...');

    try {
      await client!.removeObject(
        config.s3.bucket,
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
    if (!persistence.canSync) return const Left('offline');
    console.info('fetch: $path...');
    ListObjectsResult? result;

    try {
      result = await client!.listAllObjectsV2(
        config.s3.bucket,
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

  Future<S3FolderInfo?> fetchStorageSize() async {
    final result = await folderInfo(S3Service.to.rootPath);

    if (result.isLeft) {
      console.error('fetchStorageSize: ${result.left}');
      return null;
    }

    storageSize.value = result.right.totalSize;
    return result.right;
  }

  Future<Either<dynamic, S3FolderInfo>> folderInfo(String s3Path) async {
    if (!persistence.canSync) return const Left('offline');
    console.info('folder size: $s3Path...');
    ListObjectsResult? result;

    try {
      result = await client!.listAllObjectsV2(
        config.s3.bucket,
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
      objects: result.objects.length,
      totalSize: totalSize,
    ));
  }

  Future<Either<dynamic, File>> downloadFile({
    required String s3Path,
    required String filePath,
    bool force = false,
  }) async {
    if (!persistence.canSync && !force) return const Left('offline');
    console.info('downloading: ${ConfigService.to.s3.bucket} -> $s3Path');
    MinioByteStream? stream;

    try {
      stream = await client!.getObject(ConfigService.to.s3.bucket, s3Path);
    } catch (e, s) {
      CrashlyticsService.to.record(FlutterErrorDetails(
        exception: e,
        stack: s,
      ));

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
    if (!persistence.canSync) return const Left('offline');
    console.info('uploading...');
    uploadTotalSize.value = await file.length();
    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.s3.bucket,
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
    if (!persistence.canSync) return const Left('offline');
    console.info('creating folder...');
    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.s3.bucket,
        join(s3Path, name + '/').replaceAll('\\', '/'),
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

  List<S3Content> _objectsToContents(List<Object> objects) {
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
