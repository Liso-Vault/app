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
    // strip root address
    object = object.replaceAll('${SecretPersistence.to.longAddress}/', '');
    final result = await SupabaseService.to.deleteObjects([object]);
    if (result.isLeft) return Left(result.left);
    console.warning('response: ${result.right.data}');
    return Right(result.right);
  }

  Future<Either<dynamic, Uint8List>> download({
    required String object,
    bool force = false,
  }) async {
    if (!persistence.sync.val && !force) return const Left('offline');
    // strip root address
    object = object.replaceAll('${SecretPersistence.to.longAddress}/', '');

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
    // strip root address
    object = object.replaceAll('${SecretPersistence.to.longAddress}/', '');
    console.info('uploading: $object...');

    final presignResult = await SupabaseService.to.presignUrl(
      object: object,
      method: 'PUT',
    );

    if (presignResult.isLeft || presignResult.right.status != 200) {
      return const Left('failed to presign');
    }

    console.info('uploading: $object -> ${presignResult.right.data.url}');
    // TODO: pass object metadata
    final response = await http.put(
      Uri.parse(presignResult.right.data.url),
      body: bytes,
    );

    console.wtf(
      'upload status: ${response.statusCode} -> body: ${response.body}',
    );

    if (response.statusCode != 200) return Left(response.body);
    return const Right(true);
  }
}
