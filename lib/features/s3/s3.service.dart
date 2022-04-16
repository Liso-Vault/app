import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:either_option/either_option.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart';

import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/ui_utils.dart';
import 'model/s3_content.model.dart';

class S3Service extends GetxService with ConsoleMixin {
  static S3Service get to => Get.find();

  // VARIABLES
  Minio? client;
  final config = Get.find<ConfigService>();
  final persistence = Get.find<PersistenceService>();

  // GETTERS
  String get rootPath => '${LisoManager.walletAddress}/';
  String get backupsPath => join(rootPath, 'Backups');
  String get historyPath => join(rootPath, 'History');
  S3Content get lisoContent => S3Content(path: lisoPath);

  String get lisoPath => join(
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

  // check if s3 is ready
  Future<Either<dynamic, bool>> ready() async {
    await _prepare();
    console.info('ready...');
    bool success = false;

    try {
      client!.bucketExists(config.s3.bucket);
    } catch (e) {
      return Left(e);
    }

    return Right(success);
  }

  Future<void> syncStatus() async {
    final statResult = await stat(lisoContent);

    statResult.fold(
      (error) {
        console.error('Stat Error: $error');
        if (error is MinioError && error.message!.contains('Not Found')) {
          //
        }
      },
      (response) async {
        if (response.metaData == null || response.metaData?['client'] == null) {
          return console.error('null metadata from server');
        }

        // final server =
        //     HiveMetadata.fromJson(jsonDecode(response.metaData!['client']!));
        // final local = _localMetadata()!;

        // if (local.updatedTime == server.updatedTime) {
        //   return console.info('in sync with server');
        // } else if (local.updatedTime.isBefore(server.updatedTime)) {
        //   _syncServerVault();
        //   return console.info('local is behind server');
        // } else if (local.updatedTime.isAfter(server.updatedTime)) {
        //   // TODO: download server vault > compare everything with local
        //   // choose the most updated item between vaults and merge
        //   return console.info('local is ahead server');
        // }
      },
    );
  }

  Future<Either<dynamic, bool>> downSync() async {
    console.info('down syncing...');

    final result = await _downloadVault();

    result.fold(
      (error) => null,
      (file) {
        // TODO: down sync
        // extract archive to temp folder
        // verify extracted hive boxes
        // delete hive from disk
        // move downloaded hive boxes to main
      },
    );

    return Right(true);
  }

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
        error + ' > upSync()',
      ),
      (response) => file = response,
    );

    if (file == null) return Left('Null Archive File');
    final uploadResult = await upload(file!);
    bool success = false;

    uploadResult.fold(
      (error) => UIUtils.showSimpleDialog(
        'Error Uploading',
        error + ' > upSync()',
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

    String eTag = '';

    try {
      eTag = await client!.putObject(
        config.s3.bucket,
        lisoPath,
        Stream<Uint8List>.value(file.readAsBytesSync()),
        metadata: {'client': metadataString},
        onProgress: (size) {}, // TODO: progress bar
      );
    } catch (e) {
      return Left(e);
    }

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
    console.info('stat: ${content.path}...');

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

  Future<Either<dynamic, File>> _downloadVault() async {
    await _prepare();
    console.info('downloading...');

    MinioByteStream? stream;

    try {
      stream = await client!.getObject(ConfigService.to.s3.bucket, lisoPath);
    } catch (e) {
      return Left(e);
    }

    final file = File(LisoManager.tempVaultFilePath);
    await stream.pipe(file.openWrite());
    console.info('downloaded!');
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
