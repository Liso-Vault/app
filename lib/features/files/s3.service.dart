import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:filesize/filesize.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/features/groups/groups.controller.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/pro/pro.controller.dart';
import 'package:liso/features/shared_vaults/shared_vault.controller.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart' as minio;
import 'package:path/path.dart';

import '../../core/hive/models/group.hive.dart';
import '../../core/hive/models/item.hive.dart';
import '../../core/liso/liso_paths.dart';
import '../../core/liso/vault.model.dart';
import '../../core/utils/globals.dart';
import '../categories/categories.service.dart';
import '../groups/groups.service.dart';
import '../items/items.service.dart';
import 'model/s3_content.model.dart';
import 'model/s3_folder_info.model.dart';

class S3Service extends GetxService with ConsoleMixin {
  static S3Service get to => Get.find();

  // VARIABLES
  Minio? client;
  bool ready = false;
  bool backedUp = false;
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
  final encryptedFiles = 0.obs;
  final downloadTotalSize = 0.obs;
  final downloadedSize = 0.obs;
  final uploadTotalSize = 0.obs;
  final uploadedSize = 0.obs;
  final progressValue = 0.05.obs;
  final progressText = 'Syncing...'.obs;

  // GETTERS
  S3Content get lisoContent => S3Content(path: vaultPath);

  String get rootPath => '${Persistence.to.walletAddress.val}/';
  String get vaultPath => join(rootPath, kVaultFileName).replaceAll('\\', '/');
  String get backupsPath => join(rootPath, 'Backups').replaceAll('\\', '/');
  String get sharedPath => join(rootPath, 'Shared').replaceAll('\\', '/');
  String get sharedVaultsPath =>
      join(sharedPath, 'Vaults').replaceAll('\\', '/');

  String get filesPath => ('${join(rootPath, 'Files')}/').replaceAll('\\', '/');

  // INIT

  // FUNCTIONS

  void init() {
    try {
      if (persistence.syncProvider.val == LisoSyncProvider.custom.name) {
        // CUSTOM SYNC PROVIDER
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
        // DEFAULT SYNC PROVIDER
        client = Minio(
          endPoint: config.secrets.s3.endpoint,
          accessKey: config.secrets.s3.key,
          secretKey: config.secrets.s3.secret,
        );
      }

      ready = true;
      console.info('init');
    } catch (e, s) {
      console.error('Exception: $e, Stacktrace: $s');
      CrashlyticsService.to.record(e, s);
    }
  }

  Map<String, String> _objectMetadata() {
    final app = Globals.metadata!.app;

    return {
      'userId': AuthService.to.userId,
      'address': Persistence.to.walletAddress.val,
      'appName': app.appName,
      'appPackageName': app.packageName,
      'appVersion': app.version,
      'appBuildNumber': app.buildNumber,
    };
  }

  void _syncProgress(double value, String? message) {
    progressValue.value = value;
    if (message != null) progressText.value = message;
  }

  Future<Either<dynamic, bool>> purge() async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Left('offline');
    console.info('listing: $rootPath...');
    minio.ListObjectsResult? result;

    try {
      result = await client!.listAllObjectsV2(
        config.secrets.s3.preferredBucket,
        prefix: rootPath,
        recursive: true,
      );
    } catch (e) {
      return Left(e);
    }

    final objects = [...result.prefixes, ...result.objects.map((e) => e.key!)];

    console.info('objects: ${objects.length} -> $objects');
    console.info('purging: $rootPath...');

    try {
      await client!.removeObjects(
        config.secrets.s3.preferredBucket,
        objects,
      );
    } catch (e) {
      return Left(e);
    }

    return const Right(true);
  }

  Future<Either<dynamic, bool>> sync() async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Right(false);

    if (syncing.value) {
      console.warning('already down syncing');
      return const Right(false);
    }

    console.info('syncing...');
    syncing.value = true;
    _syncProgress(0.1, 'Syncing...');

    final statResult = await stat(lisoContent).timeout(
      syncTimeoutDuration,
      onTimeout: () => const Left('Timed Out'),
    );

    if (statResult.isLeft) {
      if (statResult.left is MinioError &&
          statResult.left.message!.contains('Not Found')) {
        inSync.value = true;
        _syncProgress(0.5, 'Initializing...');

        final upsyncResult = await upSync().timeout(
          syncTimeoutDuration,
          onTimeout: () => const Left('Timed Out'),
        );

        _syncProgress(1, '');
        syncing.value = false;
        return upsyncResult;
      }

      syncing.value = false;
      console.error('Stat Error: ${statResult.left}');
      return Left(statResult.left);
    }

    _syncProgress(0.2, 'Fetching...');

    final downResult = await _downSync().timeout(
      syncTimeoutDuration,
      onTimeout: () => const Left('Timed Out'),
    );

    if (downResult.isLeft) return Left(downResult.left);
    // we are now ready to upSync because we are not in sync with server
    inSync.value = true;
    Persistence.to.changes.val = 0;
    // up sync local changes with server
    _syncProgress(0.5, 'Pushing...');

    await upSync().timeout(
      syncTimeoutDuration,
      onTimeout: () => const Left('Timed Out'),
    );

    syncing.value = false;
    _syncProgress(1, '');
    // reload all list
    MainScreenController.to.load();

    syncSharedVaults().timeout(
      syncTimeoutDuration,
      onTimeout: () => const Left('Timed Out'),
    );

    return Right(downResult.right);
  }

  // DOWN SYNC
  Future<Either<dynamic, bool>> _downSync() async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Right(false);
    console.info('down syncing...');

    final downloadResult = await downloadFile(
      s3Path: vaultPath,
      filePath: LisoPaths.tempVaultFilePath,
    );

    if (downloadResult.isLeft) return Left(downloadResult.left);
    _syncProgress(0.3, null);

    final encryptedBytes = await downloadResult.right.readAsBytes();
    await Future.delayed(1.seconds); // fix Invalid or corrupted pad block]
    final decryptedBytes = CipherService.to.decrypt(encryptedBytes);

    final decryptedJson = utf8.decode(decryptedBytes);
    // fix decoding with double quotes
    final jsonMap = jsonDecode(decryptedJson); // TODO: isolate
    final vault = LisoVault.fromJson(jsonMap);
    _syncProgress(0.4, null);
    await _mergeGroups(vault);
    await _mergeCategories(vault);
    await _mergeItems(vault);
    return const Right(true);
  }

  Future<void> _mergeGroups(LisoVault vault) async {
    final server = vault.groups;
    final local = GroupsService.to.box!;
    console
        .wtf('merged groups local: ${local.length}, server: ${server.length}');

    // merge server and local items
    final merged = [...server, ...local.values];
    // TODO: temporarily remove previously added groups
    merged.removeWhere((e) => e.isReserved);
    // sort all from most to least updated time
    merged.sort(
      (a, b) => b.metadata!.updatedTime.compareTo(a.metadata!.updatedTime),
    );

    // exclude permanently flagged deleted items
    final deletedIds =
        "${Persistence.to.deletedGroupIds},${vault.persistence['deleted-group-ids']}";
    merged.removeWhere((e) => deletedIds.contains(e.id));

    // leave only the most updated items
    final newList = <HiveLisoGroup>[];

    for (final item in merged) {
      final exists = newList.where((e) => e.id == item.id).isNotEmpty;
      if (exists) continue;
      newList.addIf(!newList.contains(item), item);
    }

    console.wtf('merged groups: ${newList.length}');
    await local.clear();
    await local.addAll(newList);
  }

  Future<void> _mergeCategories(LisoVault vault) async {
    final server = vault.categories ?? [];
    final local = CategoriesService.to.box!;
    console.wtf(
        'merged categories local: ${local.length}, server: ${server.length}');
    // merge server and local items
    final merged = [...server, ...local.values];
    // sort all from most to least updated time
    merged.sort(
      (a, b) => b.metadata!.updatedTime.compareTo(a.metadata!.updatedTime),
    );

    // exclude permanently flagged deleted items
    final deletedIds =
        "${Persistence.to.deletedCategoryIds},${vault.persistence['deleted-category-ids']}";
    merged.removeWhere((e) => deletedIds.contains(e.id));

    // leave only the most updated items
    final newList = <HiveLisoCategory>[];

    for (final item in merged) {
      final exists = newList.where((e) => e.id == item.id).isNotEmpty;
      if (exists) continue;
      newList.addIf(!newList.contains(item), item);
    }

    console.wtf('merged categories: ${newList.length}');
    await local.clear();
    await local.addAll(newList);
  }

  Future<void> _mergeItems(LisoVault vault) async {
    final server = vault.items;
    final local = ItemsService.to.box!;
    console.wtf(
      'merged items local: ${local.length}, server: ${server.length}',
    );

    // merge server and local items
    final merged = [...server, ...local.values];
    // sort all from most to least updated time
    merged.sort(
      (a, b) => b.metadata.updatedTime.compareTo(a.metadata.updatedTime),
    );

    // exclude permanently flagged deleted items
    final deletedIds =
        "${Persistence.to.deletedItemIds},${vault.persistence['deleted-item-ids']}";
    merged.removeWhere((e) => deletedIds.contains(e.identifier));
    // leave only the most updated items
    final newList = <HiveLisoItem>[];

    for (final item in merged) {
      final exists =
          newList.where((e) => e.identifier == item.identifier).isNotEmpty;
      if (exists) continue;
      newList.addIf(!newList.contains(item), item);
    }

    console.wtf('merged items: ${newList.length}');
    await local.clear();
    await local.addAll(newList);
  }

  Future<Either<dynamic, String>> backup(
      S3Content content, Uint8List encryptedBytes) async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Left('offline');
    if (backedUp) return const Left('already backed up for todays session');
    console.info('backup: ${content.path}...');

    // REMOVE OLDEST BACKUP IF NECESSARY
    final result = await folderInfo(S3Service.to.backupsPath);

    if (result.isLeft) {
      console.error('backups folder info error: ${result.left}');
      return Left(result.isLeft);
    }

    final info = result.right;

    // console.wtf('# BACKUPS #');
    // console.wtf(
    //   'limits: ${ProController.to.limits.backups}, backups: ${info.contents.length}',
    // );

    // for (var e in info.contents) {
    //   console.wtf('${e.name} - ${e.object?.lastModified}');
    // }

    if (info.contents.length >= ProController.to.limits.backups) {
      final result = await remove(info.contents.first);
      // abort backup if error in removing oldest backup
      if (result.isLeft) {
        console.error('error removing last backup: ${result.left}');
        return Left(result.left);
      } else {
        console.wtf(
          'removed backup: ${result.right} - ${info.contents.first.name}',
        );
      }
    }

    // DO THE ACTUAL BACKUP
    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.secrets.s3.preferredBucket,
        join(
          backupsPath,
          '${DateTime.now().millisecondsSinceEpoch}-$kVaultFileName',
        ).replaceAll('\\', '/'),
        Stream<Uint8List>.value(encryptedBytes),
        onProgress: (size) => uploadedSize.value = size,
        metadata: _objectMetadata(),
      );
    } catch (e) {
      return Left(e);
    }

    backedUp = true;
    return Right(eTag);

    // try {
    //   final result = await client!.copyObject(
    //     config.secrets.s3.preferredBucket,
    //     content.path,
    //     backupsPath,
    //     // CopyConditions(),
    //   );

    //   return Right(result);
    // } catch (e) {
    //   return Left(e);
    // }
  }

  // UP SYNC
  Future<Either<dynamic, bool>> upSync() async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Left('offline');
    if (!inSync.value) {
      return const Left('not in sync with server');
    }

    console.info('up syncing...');

    // UPLOAD
    _syncProgress(0.7, null);
    final vaultJsonString = await LisoManager.compactJson();

    final encryptedBytes = CipherService.to.encrypt(
      utf8.encode(vaultJsonString),
    );

    // BACKUP
    backup(lisoContent, encryptedBytes).then((result) {
      if (result.isLeft) {
        console.warning('Failed to backup: ${result.left}');
      } else {
        console.info('backed up! eTag: ${result.right}');
      }
    });

    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.secrets.s3.preferredBucket,
        vaultPath,
        Stream<Uint8List>.value(encryptedBytes),
        onProgress: (size) => uploadedSize.value = size,
        metadata: _objectMetadata(),
      );
    } catch (e) {
      return Left(e);
    }

    _syncProgress(0.9, null);
    console.info('uploaded: $eTag');
    return const Right(true);
  }

  Future<Either<dynamic, bool>> syncSharedVaults() async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Left('offline');

    if (SharedVaultsController.to.data.isEmpty) {
      return const Left('nothing to sync');
    }

    if (syncingSharedVaults.value) {
      return const Left('still syncing shared vaults');
    }

    console.info(
      'syncing ${SharedVaultsController.to.data.length} shared vaults...',
    );

    for (final sharedVault in SharedVaultsController.to.data) {
      final sharedItems = ItemsService.to.data
          .where((item) => item.sharedVaultIds.contains(sharedVault.docId))
          .toList();

      final cipherKeyResult = await ItemsService.to.obtainFieldValue(
        itemId: sharedVault.docId,
        fieldId: 'key',
      );

      if (cipherKeyResult.isLeft) {
        // UIUtils.showSimpleDialog(
        //   'Cipher Key Not Found',
        //   cipherKeyResult.left,
        // );

        console.error('Cipher Key Not Found');
        return const Left('value');
      }

      final sharedItemsJson = List<dynamic>.from(
        sharedItems.map((x) => x.toJson()),
      );

      final sharedItemsJsonString = jsonEncode(sharedItemsJson);
      final bytes = Uint8List.fromList(utf8.encode(sharedItemsJsonString));

      final encryptedBytes = CipherService.to.encrypt(
        bytes,
        cipherKey: base64Decode(cipherKeyResult.right),
      );

      String eTag = '';
      final s3path = join(sharedPath, '${sharedVault.docId}.$kVaultExtension');
      console.warning('uploading: $s3path');

      try {
        eTag = await client!.putObject(
          config.secrets.s3.preferredBucket,
          s3path,
          Stream<Uint8List>.value(encryptedBytes),
          onProgress: (size) => uploadedSize.value = size,
          metadata: _objectMetadata(),
        );
      } catch (e) {
        return Left(e);
      }

      console.info('uploaded: $eTag');
    }

    console.wtf('done');
    return const Right(true);
  }

  Future<Either<dynamic, minio.StatObjectResult>> stat(
      S3Content content) async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Left('offline');
    console.info(
      'stat: ${config.secrets.s3.preferredBucket}->${basename(content.path)}...',
    );

    try {
      final result = await client!.statObject(
        config.secrets.s3.preferredBucket,
        content.path,
      );

      return Right(result);
    } catch (e) {
      return Left(e);
    }
  }

  Future<Either<dynamic, bool>> remove(S3Content content) async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Left('offline');
    console.info('removing: ${content.path}...');

    try {
      await client!.removeObject(
        config.secrets.s3.preferredBucket,
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
    if (!persistence.sync.val && ready) return const Left('offline');
    console.info('fetch: $path...');
    minio.ListObjectsResult? result;

    try {
      result = await client!.listAllObjectsV2(
        config.secrets.s3.preferredBucket,
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
    if (!persistence.sync.val && ready) return const Left('offline');
    console.info('folder size: $s3Path...');
    minio.ListObjectsResult? result;

    try {
      result = await client!.listAllObjectsV2(
        config.secrets.s3.preferredBucket,
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
    int encryptedFiles = 0;

    final contents = _objectsToContents(result.objects);

    for (var e in contents) {
      totalSize += e.size;
      if (e.isEncrypted) encryptedFiles++;
    }

    console.info('total size: $totalSize');

    return Right(S3FolderInfo(
      contents: contents,
      totalSize: totalSize,
      encryptedFiles: encryptedFiles,
    ));
  }

  Future<Either<dynamic, String>> getPreSignedUrl(String s3Path) async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Left('offline');
    console.info('pre signing: $s3Path...');
    String? result;

    try {
      result = await client!.presignedGetObject(
        config.secrets.s3.preferredBucket,
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
    if (!persistence.sync.val && ready && !force) return const Left('offline');

    console.info(
      'downloading: ${config.secrets.s3.preferredBucket} -> $s3Path',
    );

    MinioByteStream? stream;

    try {
      stream = await client!.getObject(
        config.secrets.s3.preferredBucket,
        s3Path,
      );
    } catch (e, s) {
      console.error('downloadFile error -> $e');

      if (!e.toString().contains('The specified key does not exist')) {
        CrashlyticsService.to.record(e, s);
      }

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
  }) async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Left('offline');
    console.info('uploading...');
    uploadTotalSize.value = await file.length();
    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.secrets.s3.preferredBucket,
        s3Path,
        Stream<Uint8List>.value(file.readAsBytesSync()),
        onProgress: (size) => uploadedSize.value = size,
        metadata: _objectMetadata(),
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
  }) async {
    if (!ready) init();
    if (!persistence.sync.val && ready) return const Left('offline');
    console.info('creating folder...');
    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.secrets.s3.preferredBucket,
        join(s3Path, '$name/').replaceAll('\\', '/'),
        Stream<Uint8List>.value(Uint8List(0)),
        metadata: _objectMetadata(),
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
    objectsCount.value = info.contents.length;
    encryptedFiles.value = info.encryptedFiles;
    // cache objects
    contentsCache = info.contents;

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
}
