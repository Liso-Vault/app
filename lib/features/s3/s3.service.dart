import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:either_option/either_option.dart';
import 'package:filesize/filesize.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/utils/ui_utils.dart';
import 'model/s3_content.model.dart';

class S3Service extends GetxService with ConsoleMixin {
  static S3Service get to => Get.find();

  // VARIABLES
  Minio? client;
  final config = Get.find<ConfigService>();
  final persistence = Get.find<PersistenceService>();
  bool canUpSync = false;

  // PROPERTIES
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

  // FUNCTIONS

  Future<void> _prepare() async {
    if (client == null || client!.endPoint.isEmpty) await init();
  }

  Future<void> init() async {
    if (config.s3.endpoint.isEmpty) await config.fetch();
    console.info('init...');

    client = Minio(
      endPoint: config.s3.endpoint,
      accessKey: config.s3.key,
      secretKey: config.s3.secret,
    );
  }

  // CAN DOWN SYNC
  Future<StatObjectResult?> _canDownSync() async {
    if (persistence.changes.val > 0) {
      console.error('there are still unsynced changes');
      return null;
    }

    console.info('_canDownSync...');
    final statResult = await stat(lisoContent);
    StatObjectResult? statObject;

    statResult.fold(
      (error) {
        if (error is MinioError && error.message!.contains('Not Found')) {
          // user has never synced, let him do it's first upSync
          canUpSync = true;
          console.error('Vault not found. User must be new');
        } else {
          console.error('Stat Error: $error');
        }
      },
      (response) {
        statObject = response;
      },
    );

    if (statObject?.metaData?['client'] == null) {
      console.warning('new user / null metadata from server');
      canUpSync = true;
      return null;
    }

    final server = HiveMetadata.fromJson(
      jsonDecode(statObject!.metaData!['client']!),
    );

    final local = _localMetadata();
    console.info('local: ${local?.updatedTime}, server: ${server.updatedTime}');

    if (local != null && local.updatedTime == server.updatedTime) {
      console.info('in sync with server');
      canUpSync = true;
      return null;
    }

    return statObject;
  }

  // DOWN SYNC
  Future<void> downSync() async {
    final statObject = await _canDownSync();
    if (statObject == null) return console.error('stat object is null');

    // TODO: download server vault > compare everything with local
    // choose the most updated item between vaults and merge

    console.info('down syncing...');
    final downloadResult = await downloadVault(path: vaultPath);
    File? vaultFile;
    dynamic _error;

    downloadResult.fold(
      (error) => _error = error,
      (file) => vaultFile = file,
    );

    if (_error != null) {
      return UIUtils.showSimpleDialog(
        'Error Downloading',
        '$_error > downSync()',
      );
    }

    final readResult = LisoManager.readArchive(vaultFile!.path);
    Archive? archive;

    readResult.fold(
      (error) => _error = error,
      (response) => archive = response,
    );

    console.info('archive files: ${archive!.files.length}');

    // check if archive contains files
    if (_error != null || archive!.files.isEmpty) {
      return UIUtils.showSimpleDialog(
        'Error Archive',
        '$_error > downSync()',
      );
    }

    await HiveManager.closeBoxes();
    // extract boxes
    await LisoManager.extractArchive(
      archive!,
      path: LisoManager.hivePath,
    );

    await HiveManager.openBoxes();
    // we are now ready to upSync because we are not in sync with server
    canUpSync = true;

    // save updated local metadata
    final server = HiveMetadata.fromJson(
      jsonDecode(statObject.metaData!['client']!),
    );

    persistence.metadata.val = server.toJsonString();
    console.warning('downloaded and in sync!');
  }

  // UP SYNC
  Future<Either<dynamic, bool>> upSync() async {
    console.info('syncing...');
    final backupResult = await backup(lisoContent);

    backupResult.fold(
      (error) => console.warning('Failed to backup: $error'),
      (response) => console.info(
        'success! eTag: ${response.eTag}, lastModified: ${response.lastModified}',
      ),
    );

    final archiveResult = await LisoManager.createArchive(
      Directory(LisoManager.hivePath),
      filePath: LisoManager.tempVaultFilePath,
    );

    File? file;
    archiveResult.fold(
      (error) => UIUtils.showSimpleDialog(
        'Error Archiving',
        '$error > upSync()',
      ),
      (response) => file = response,
    );

    if (file == null) return Left('Null Archive File');
    final uploadResult = await upload(file!);
    bool success = false;

    uploadResult.fold(
      (error) => UIUtils.showSimpleDialog(
        'Error Uploading',
        '$error > upSync()',
      ),
      (response) {
        success = true;
        console.info('uploaded! eTag: $response');
      },
    );

    return Right(success);
  }

  Future<Either<dynamic, String>> upload(File file) async {
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

    // reset download indicators
    uploadTotalSize.value = 0;
    uploadedSize.value = 0;

    // save updated local metadata
    persistence.metadata.val = metadataString;
    return Right(eTag);
  }

  Future<Either<dynamic, CopyObjectResult>> backup(S3Content content) async {
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

  Future<Either<dynamic, File>> downloadVault({required String path}) async {
    await _prepare();
    console.info('downloading...');
    MinioByteStream? stream;

    try {
      stream = await client!.getObject(ConfigService.to.s3.bucket, path);
    } catch (e) {
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
