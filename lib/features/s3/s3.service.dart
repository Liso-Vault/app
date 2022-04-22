import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:filesize/filesize.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/hive/models/item.hive.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/utils/file.util.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/ui_utils.dart';
import 'model/s3_content.model.dart';

class S3Service extends GetxService with ConsoleMixin {
  static S3Service get to => Get.find();

  // VARIABLES
  Minio? client;
  final config = Get.find<ConfigService>();
  final persistence = Get.find<PersistenceService>();

  // PROPERTIES
  final syncing = false.obs;
  final inSync = false.obs;
  final downloadTotalSize = 0.obs;
  final downloadedSize = 0.obs;
  final uploadTotalSize = 0.obs;
  final uploadedSize = 0.obs;

  // GETTERS
  String get rootPath => '${LisoManager.walletAddress}/';
  String get backupsPath => join(rootPath, 'Backups');
  String get historyPath => join(rootPath, 'History');
  S3Content get lisoContent => S3Content(path: vaultPath);

  String get vaultPath => join(
        LisoManager.walletAddress,
        LisoManager.vaultFilename,
      );

  // INIT
  @override
  void onInit() {
    _init();
    super.onInit();
  }

  // FUNCTIONS
  Future<void> _prepare() async {
    if (client == null || client!.endPoint.isEmpty) {
      await _init();
    } else {
      console.error('service is not initialized');
    }
  }

  Future<void> _init() async {
    if (config.s3.endpoint.isEmpty) await config.fetch();
    console.info('init...');

    client = Minio(
      endPoint: config.s3.endpoint,
      accessKey: config.s3.key,
      secretKey: config.s3.secret,
    );
  }

  Future<void> sync() async {
    if (!persistence.canSync) return;
    if (syncing.value) return console.warning('already down syncing');
    console.info('syncing...');
    syncing.value = true;

    final statResult = await stat(lisoContent);

    if (statResult.isLeft) {
      if (statResult.left is MinioError &&
          statResult.left.message!.contains('Not Found')) {
        console.error('New cloud user: upsync current vault');
        inSync.value = true;
        await upSync();
      } else {
        console.error('Stat Error: $statResult.left');
      }

      return;
    }

    final serverMetadata = HiveMetadata.fromJson(
      jsonDecode(statResult.right.metaData!['client']!),
    );

    await _downSync(serverMetadata);

    syncing.value = false;
    MainScreenController.to.load();
  }

  // CAN DOWN SYNC
  // Future<void> tryDownSync() async {
  //   if (!persistence.canSync) return;
  //   console.info('tryDownSync...');
  //   final statResult = await stat(lisoContent);

  //   if (statResult.isLeft) {
  //     if (statResult.left is MinioError &&
  //         statResult.left.message!.contains('Not Found')) {
  //       console.error('New cloud user: upsync current vault');
  //       inSync.value = true;
  //     } else {
  //       console.error('Stat Error: $statResult.left');
  //     }

  //     return;
  //   }

  //   final server = HiveMetadata.fromJson(
  //     jsonDecode(statResult.right.metaData!['client']!),
  //   );

  //   final local = _localMetadata();
  //   console.info('local: ${local?.updatedTime}, server: ${server.updatedTime}');

  //   // if (local != null && local.updatedTime == server.updatedTime) {
  //   //   console.info('in sync with server');
  //   //   SyncService.to.inSync.value = true;
  //   //   return;
  //   // }

  //   _downSync(server);
  // }

  // DOWN SYNC
  Future<void> _downSync(HiveMetadata serverMetadata) async {
    if (!persistence.canSync) return;
    console.info('down syncing...');
    final downloadResult = await downloadVault(path: vaultPath);

    if (downloadResult.isLeft) {
      return UIUtils.showSimpleDialog(
        'Error Downloading',
        '${downloadResult.left} > downSync()',
      );
    }

    final vaultFile = downloadResult.right;
    final readResult = LisoManager.readArchive(vaultFile.path);
    FileUtils.delete(vaultFile.path); // delete temporary vault file

    if (readResult.isLeft) {
      return UIUtils.showSimpleDialog(
        'Error Archive',
        '${readResult.left} > downSync()',
      );
    }

    // extract boxes
    final extractResult = await LisoManager.extractArchive(
      readResult.right,
      path: LisoManager.tempPath,
      fileNamePrefix: 'temp_',
    );

    if (extractResult.isLeft) {
      return UIUtils.showSimpleDialog(
        'Error Archive',
        '${extractResult.left} > downSync()',
      );
    }

    // save updated local metadata
    persistence.metadata.val = serverMetadata.toJsonString();
    console.warning('downloaded and in sync!');
    await HiveManager.unwatchBoxes();
    await _mergeItems(box: kHiveBoxItems);
    await _mergeItems(box: kHiveBoxArchived);
    await _mergeItems(box: kHiveBoxTrash);
    HiveManager.watchBoxes();
    MainScreenController.to.load();
    // we are now ready to upSync because we are not in sync with server
    inSync.value = true;
    PersistenceService.to.changes.val = 0;
    // up sync local changes with server
    await upSync();
  }

  Future<void> _mergeItems({required String box}) async {
    Box<HiveLisoItem>? localItems;

    if (box == kHiveBoxItems) {
      localItems = HiveManager.items!;
    } else if (box == kHiveBoxArchived) {
      localItems = HiveManager.archived!;
    } else if (box == kHiveBoxTrash) {
      localItems = HiveManager.trash!;
    }

    final tempItems = await Hive.openBox<HiveLisoItem>(
      'temp_$box',
      encryptionCipher: HiveAesCipher(Globals.encryptionKey),
      path: LisoManager.tempPath,
    );

    if (tempItems.isEmpty) {
      await tempItems.clear();
      await tempItems.deleteFromDisk();
      return console.warning('temp items is empty');
    }

    console.warning('server items: ${tempItems.length}');
    console.warning('local items: ${localItems!.length}');

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

    // console.info('final: ${mergedItems.length}');
    // for (var e in mergedItems) {
    //   console.warning(
    //     '${e.identifier} - ${e.metadata.updatedTime}',
    //   );
    // }

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

    if (archiveResult.isLeft) {
      UIUtils.showSimpleDialog(
        'Error Archiving',
        '${archiveResult.left} > upSync()',
      );

      return Left(archiveResult.left);
    }

    // UPLOAD
    final uploadResult = await _uploadVault(archiveResult.right);

    if (uploadResult.isLeft) {
      UIUtils.showSimpleDialog(
        'Error Uploading',
        '${uploadResult.left} > upSync()',
      );

      return Left(uploadResult.left);
    }

    console.info('uploaded! eTag: ${uploadResult.right}');
    return const Right(true);
  }

  Future<Either<dynamic, String>> _uploadVault(File file) async {
    if (!persistence.canSync) return const Left('offline');
    await _prepare();
    console.info('upload...');
    final metadataString = await _updatedLocalMetadata();
    uploadTotalSize.value = await file.length();
    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.s3.bucket,
        vaultPath,
        Stream<Uint8List>.value(file.readAsBytesSync()),
        metadata: {'client': metadataString},
        onProgress: (size) => uploadedSize.value = size,
      );
    } catch (e) {
      return Left(e);
    }

    file.delete(); // delete temp vault file
    // reset download indicators
    uploadTotalSize.value = 0;
    uploadedSize.value = 0;
    // save updated local metadata
    persistence.metadata.val = metadataString;
    return Right(eTag);
  }

  Future<Either<dynamic, CopyObjectResult>> backup(S3Content content) async {
    if (!persistence.canSync) return const Left('offline');
    await _prepare();
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
    await _prepare();
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

  Future<Either<dynamic, List<S3Content>>> fetch({
    required String path,
    S3ContentType? filterType,
    List<String> filterExtensions = const [],
  }) async {
    if (!persistence.canSync) return const Left('offline');
    await _prepare();
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

  Future<Either<dynamic, File>> downloadVault({
    required String path,
    bool force = false,
  }) async {
    if (!persistence.canSync && !force) return const Left('offline');
    await _prepare();
    console.info('downloading: ${ConfigService.to.s3.bucket} -> $path');
    MinioByteStream? stream;

    try {
      stream = await client!.getObject(ConfigService.to.s3.bucket, path);
    } catch (e) {
      console.error('download error: $e');
      return Left(e);
    }

    console.info('download size: ${filesize(stream.contentLength)}');
    final file = File(LisoManager.tempVaultFilePath);
    await stream.pipe(file.openWrite());
    console.info('downloaded to: ${LisoManager.tempVaultFilePath}');
    return Right(file);
  }

  List<S3Content> _objectsToContents(List<Object> objects) {
    return objects
        .map(
          (e) => S3Content(
            name: basename(e.key!),
            path: e.key!,
            size: e.size!,
            type: extension(e.key!).isNotEmpty
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

  Future<String> _updatedLocalMetadata() async {
    final metadata = _localMetadata() ?? await HiveMetadata.get();
    return (await metadata.getUpdated()).toJsonString();
  }
}
