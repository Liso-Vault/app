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
import '../../core/utils/file.util.dart';
import '../../core/utils/ui_utils.dart';
import '../sync/sync.service.dart';
import 'model/s3_content.model.dart';

class S3Service extends GetxService with ConsoleMixin {
  static S3Service get to => Get.find();

  // VARIABLES
  Minio? client;
  final config = Get.find<ConfigService>();
  final persistence = Get.find<PersistenceService>();

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
  @override
  void onInit() {
    init();
    super.onInit();
  }

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
  Future<void> tryDownSync() async {
    if (!persistence.canSync) return;
    console.info('tryDownSync...');
    final statResult = await stat(lisoContent);
    StatObjectResult? statObject;

    statResult.fold(
      (error) {
        if (error is MinioError && error.message!.contains('Not Found')) {
          console.error('New cloud user: upsync current vault');
          SyncService.to.inSync.value = true;
          upSync();
        } else {
          console.error('Stat Error: $error');
        }
      },
      (response) => statObject = response,
    );

    if (statObject?.metaData?['client'] == null) return;

    final server = HiveMetadata.fromJson(
      jsonDecode(statObject!.metaData!['client']!),
    );

    final local = _localMetadata();
    console.info('local: ${local?.updatedTime}, server: ${server.updatedTime}');

    if (local != null && local.updatedTime == server.updatedTime) {
      console.info('in sync with server');
      SyncService.to.inSync.value = true;
      return;
    }

    _downSync(server);
  }

  // DOWN SYNC
  Future<void> _downSync(HiveMetadata serverMetadata) async {
    if (!persistence.canSync) return;
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
    FileUtils.delete(vaultFile!.path); // delete temporary vault file
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

    // await HiveManager.closeBoxes();
    // extract boxes
    await LisoManager.extractArchive(
      archive!,
      path: LisoManager.tempPath,
      fileNamePrefix: 'temp_',
    );
    // open boxes
    // await HiveManager.openBoxes();

    // we are now ready to upSync because we are not in sync with server
    SyncService.to.inSync.value = true;
    PersistenceService.to.changes.val = 0;
    // save updated local metadata
    persistence.metadata.val = serverMetadata.toJsonString();
    console.warning('downloaded and in sync!');
  }

  // UP SYNC
  Future<Either<dynamic, bool>> upSync() async {
    if (!SyncService.to.inSync.value) return Left('not in sync with server');
    if (!persistence.canSync) return Left('offline');
    console.info('syncing...');
    final backupResult = await backup(lisoContent);

    backupResult.fold(
      (error) => console.warning('Failed to backup: $error'),
      (response) => console.info(
        'success! eTag: ${response.eTag}, lastModified: ${response.lastModified}',
      ),
    );

    await HiveManager.closeBoxes();
    final archiveResult = await LisoManager.createArchive(
      Directory(LisoManager.hivePath),
      filePath: LisoManager.tempVaultFilePath,
    );
    await HiveManager.openBoxes();

    File? file;
    archiveResult.fold(
      (error) => UIUtils.showSimpleDialog(
        'Error Archiving',
        '$error > upSync()',
      ),
      (response) => file = response,
    );

    if (file == null) return Left('Null Archive File');
    final uploadResult = await _uploadVault(file!);
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

  Future<Either<dynamic, String>> _uploadVault(File file) async {
    if (!persistence.canSync) return Left('offline');
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
    if (!persistence.canSync) return Left('offline');
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
    if (!persistence.canSync) return Left('offline');
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
    if (!persistence.canSync) return Left('offline');
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
    if (!persistence.canSync && !force) return Left('offline');
    await _prepare();
    console.info('downloading: ${ConfigService.to.s3.bucket} -> $path');
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
