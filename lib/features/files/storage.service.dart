import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/persistence/persistence.secret.dart';
import 'package:liso/core/supabase/supabase.service.dart';

import '../../core/supabase/model/generic_response.model.dart';
import '../../core/supabase/model/list_objects_response.model.dart';
import '../../core/supabase/model/object.model.dart';

class StorageService extends GetxService with ConsoleMixin {
  static StorageService get to => Get.find();

  // VARIABLES
  final config = Get.find<ConfigService>();
  final persistence = Get.find<Persistence>();
  final rootInfo = const ListObjectsResponse().obs;

  // PROPERTIES

  // GETTERS
  List<S3Object> get backups {
    final path = '${SecretPersistence.to.longAddress}/Backups/';

    return StorageService.to.rootInfo.value.data.objects
        .where((e) => e.key.startsWith(path))
        .toList();
  }

  // INIT

  // FUNCTIONS

  Future<void> load() async {
    final result = await SupabaseService.to.listObjects();
    if (result.isLeft) console.error('failed to list objects');
    rootInfo.value = result.right;
  }

  Future<Either<dynamic, GenericResponse>> remove(String object) async {
    if (!persistence.sync.val) return const Left('offline');
    final result = await SupabaseService.to.deleteObjects([object]);
    if (result.isLeft) return Left(result.left);
    return Right(result.right);
  }

  Future<Either<dynamic, List<S3Object>>> fetch({
    required String path,
    S3ObjectType? filterType,
    List<String> filterExtensions = const [],
  }) async {
    // if (!ready) init();
    // if (!persistence.sync.val && ready) return const Left('offline');
    // console.info('fetch: $path...');
    // minio.ListObjectsResult? result;

    // try {
    //   result = await client!.listAllObjectsV2(
    //     config.secrets.s3.preferredBucket,
    //     prefix: path,
    //   );
    // } catch (e) {
    //   return Left(e);
    // }

    // console.info(
    //   'prefixes: ${result.prefixes.length}, objects: ${result.objects.length}',
    // );

    // // remove current directory
    // result.objects.removeWhere(
    //   (e) => e.key == path || !e.key!.contains(rootPath),
    // );

    List<S3Object> contents = [];
    // // convert prefixes to content
    // if (filterType == null || filterType == S3ContentType.directory) {
    //   contents.addAll(_prefixesToContents(result.prefixes));
    // }

    // // convert objects to content
    // if (filterType == null || filterType == S3ContentType.file) {
    //   var filtered = result.objects;
    //   // filter by extension
    //   if (filterExtensions.isNotEmpty) {
    //     filtered = result.objects
    //         .where((e) => filterExtensions.contains(extension(e.key!)))
    //         .toList();
    //   }

    //   contents.addAll(_objectsToContents(filtered));
    // }

    return Right(contents);
  }

  Future<Either<dynamic, Uint8List>> download({
    required String object,
    bool force = false,
  }) async {
    if (!persistence.sync.val && !force) return const Left('offline');

    final presignResult = await SupabaseService.to.presignUrl(
      object: object,
      method: 'GET',
    );

    if (presignResult.isLeft || presignResult.right.status != 200) {
      console.error('presign error: ${presignResult.right.data.toJson()}');
      return const Left('failed to presign');
    }

    console.info('downloading: $object...');
    final response = await http.get(Uri.parse(presignResult.right.data.url));

    if (response.statusCode != 200) {
      console.error(
          'download status: ${response.statusCode}, body: ${response.body}');
      return Left(response.body);
    }

    console.info('size: ${filesize(response.contentLength)}');
    return Right(response.bodyBytes);
  }

  Future<Either<dynamic, bool>> upload(
    Uint8List bytes, {
    required String object,
  }) async {
    if (!persistence.sync.val) return const Left('offline');
    console.info('uploading...');

    final presignResult = await SupabaseService.to.presignUrl(
      object: object,
      method: 'PUT',
    );

    if (presignResult.isLeft || presignResult.right.status != 200) {
      return const Left('failed to presign');
    }

    console.info('uploading: $object...');
    // TODO: pass object metadata
    final response = await http.put(
      Uri.parse(presignResult.right.data.url),
      body: bytes,
    );

    if (response.statusCode != 200) {
      console.error(
          'upload status: ${response.statusCode}, body: ${response.body}');
      return Left(response.body);
    }

    return const Right(true);
  }

  Future<Either<dynamic, bool>> createFolder(
    String name, {
    required String s3Path,
  }) async {
    if (!persistence.sync.val) return const Left('offline');
    console.info('creating folder...');

    // try {
    //   eTag = await client!.putObject(
    //     config.secrets.s3.preferredBucket,
    //     join(s3Path, '$name/').replaceAll('\\', '/'),
    //     Stream<Uint8List>.value(Uint8List(0)),
    //     metadata: _objectMetadata(),
    //   );
    // } catch (e) {
    //   return Left(e);
    // }

    return const Right(true);
  }

  // Future<S3FolderInfo?> fetchStorageSize() async {
  //   final result = await folderInfo(''); // root path

  //   if (result.isLeft) {
  //     console.error('fetchStorageSize: ${result.left}');
  //     return null;
  //   }

  //   // final info = result.right;
  //   // storageSize.value = info.totalSize;
  //   // objectsCount.value = info.contents.length;
  //   // encryptedFiles.value = info.encryptedFiles;
  //   // // cache objects
  //   // contentsCache = info.contents;

  //   // return info;

  //   return null;
  // }
}
