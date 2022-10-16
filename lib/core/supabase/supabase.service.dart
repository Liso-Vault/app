import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:liso/core/persistence/persistence.secret.dart';
import 'package:liso/core/supabase/model/list_objects_response.model.dart';
import 'package:liso/core/supabase/model/presign_response.model.dart';
import 'package:liso/core/supabase/model/stat_response.model.dart';
import 'package:supabase/supabase.dart';

import '../firebase/config/config.service.dart';
import 'model/server_response.model.dart';

const kFunctionPresignUrl = 'presign-url';
const kFunctionListObjects = 'list-objects';
const kFunctionStatObject = 'stat-object';
const kFunctionDeleteDirectory = 'delete-directory';
const kFunctionDeleteObjects = 'delete-objects';

class SupabaseService extends GetxService with ConsoleMixin {
  static SupabaseService get to => Get.find();

  // VARIABLES
  final config = Get.find<ConfigService>();
  final spersistence = Get.find<SecretPersistence>();
  late SupabaseClient client;

  // GETTERS

  @override
  void onReady() {
    init();
    super.onReady();
  }

  // FUNCTIONS
  void init() {
    final s = config.secrets.supabase;
    client = SupabaseClient(s.url, s.key);
  }

  Future<Either<Object?, StatObjectResponse>> statObject(String object,
      {String? address}) async {
    // strip root address
    object = object.replaceAll('${SecretPersistence.to.longAddress}/', '');
    console.info('stat: $object....');

    final response = await client.functions.invoke(
      kFunctionStatObject,
      body: {
        "address": address ?? spersistence.walletAddress.val,
        "object": object,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.error}');
    if (response.error != null) return Left(response.error);
    return Right(StatObjectResponse.fromJson(response.data));
  }

  Future<Either<Object?, ListObjectsResponse>> listObjects(
      {String path = ''}) async {
    // strip root address
    path = path.replaceAll('${SecretPersistence.to.longAddress}/', '');
    console.info('list objects: $path....');

    final response = await client.functions.invoke(
      kFunctionListObjects,
      body: {
        "address": spersistence.walletAddress.val,
        "path": path,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.error}');
    if (response.error != null) return Left(response.error);
    return Right(ListObjectsResponse.fromJson(response.data));
  }

  Future<Either<Object?, ServerResponse>> deleteObjects(
      List<String> objects) async {
    // strip root address
    objects = objects
        .map((e) => e.replaceAll('${SecretPersistence.to.longAddress}/', ''))
        .toList();

    console.info('delete objects: $objects....');

    final response = await client.functions.invoke(
      kFunctionDeleteObjects,
      body: {
        "address": spersistence.walletAddress.val,
        "objects": objects,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.error}');
    if (response.error != null) return Left(response.error);
    return Right(ServerResponse.fromJson(response.data));
  }

  Future<Either<Object?, ListObjectsResponse>> deleteDirectory(
      String path) async {
    // strip root address
    path = path.replaceAll('${SecretPersistence.to.longAddress}/', '');
    console.info('delete directory: $path....');

    final response = await client.functions.invoke(
      kFunctionDeleteDirectory,
      body: {
        "address": spersistence.walletAddress.val,
        "path": path,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.error}');
    if (response.error != null) return Left(response.error);
    return Right(ListObjectsResponse.fromJson(response.data));
  }

  Future<Either<Object?, PresignUrlResponse>> presignUrl({
    required String object,
    String? address,
    String method = "GET",
    int expirySeconds = 1000,
  }) async {
    // strip root address
    object = object.replaceAll('${SecretPersistence.to.longAddress}/', '');
    console.info('presigning: $object....');

    final response = await client.functions.invoke(
      kFunctionPresignUrl,
      body: {
        "address": address ?? spersistence.walletAddress.val,
        "object": object,
        "method": method,
        "expirySeconds": expirySeconds,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.error}');
    if (response.error != null) return Left(response.error);
    return Right(PresignUrlResponse.fromJson(response.data));
  }
}
