import 'dart:io';
import 'dart:typed_data';

import 'package:either_option/either_option.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart';

import '../../core/utils/extensions.dart';
import '../../core/utils/globals.dart';
import 'model/s3_content.model.dart';

class S3Service extends GetxService with ConsoleMixin {
  static S3Service get to => Get.find();

  // VARIABLES
  Minio? client;

  // GETTERS
  String get rootPath => '${masterWallet!.address}/';

  // INIT

  // FUNCTIONS

  void init() {
    final config = Get.find<ConfigService>();

    client = Minio(
      endPoint: config.s3.endpoint,
      accessKey: config.s3.key,
      secretKey: config.s3.secret,
    );

    console.warning('endpoint: ${client!.endPoint}');
  }

  // check if s3 is ready
  Future<bool> ready() => client!.bucketExists(ConfigService.to.s3.bucket);

  Future<Either<String, String>> upload(File file) async {
    try {
      final eTag = await S3Service.to.client!.putObject(
        ConfigService.to.s3.bucket,
        S3Service.to.rootPath + masterWallet!.address + '.$kVaultExtension',
        Stream<Uint8List>.value(file.readAsBytesSync()),
        onProgress: (size) {
          // console.info('uploading: $size');
        },
      );

      return Right(eTag);
    } catch (e) {
      return Left('Error Uploading: $e > upload()');
    }
  }

  Future<List<S3Content>> fetch({
    required String path,
    S3ContentType? filterType,
    List<String> filterExtensions = const [],
  }) async {
    final result = await client!.listAllObjectsV2(
      ConfigService.to.s3.bucket,
      prefix: path,
    );

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

    return contents;
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
}
