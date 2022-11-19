import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/supabase/model/server_response.model.dart';
import 'package:app_core/supabase/supabase_functions.service.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:secrets/secrets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/persistence/persistence.dart';
import '../../core/persistence/persistence.secret.dart';
import '../categories/categories.service.dart';
import '../files/storage.service.dart';
import '../groups/groups.service.dart';
import '../items/items.service.dart';
import '../joined_vaults/joined_vault.controller.dart';
import '../shared_vaults/shared_vault.controller.dart';
import 'model/list_objects_response.model.dart';
import 'model/presign_response.model.dart';
import 'model/stat_response.model.dart';

class AppSupabaseFunctionsService extends SupabaseFunctionsService {
  static AppSupabaseFunctionsService get to => Get.find();

  // VARIABLES
  final persistence = Get.find<Persistence>();
  final spersistence = Get.find<SecretPersistence>();

  // GETTERS

  // INIT

  // FUNCTIONS

  Future<Either<Object?, StatObjectResponse>> statObject(String object,
      {String? address}) async {
    // strip root address
    object = object.replaceAll('${spersistence.walletAddress.val}/', '');
    console.info('stat: $object....');

    final response = await auth.client!.functions.invoke(
      kFunctionStatObject,
      body: {
        "address": address ?? spersistence.walletAddress.val,
        "object": object,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.status}');

    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    return Right(StatObjectResponse.fromJson(response.data));
  }

  Future<Either<Object?, ListObjectsResponse>> listObjects(
      {String path = ''}) async {
    // strip root address
    path = path.replaceAll('${spersistence.walletAddress.val}/', '');
    console.info('list objects: $path....');

    final response = await auth.client!.functions.invoke(
      kFunctionListObjects,
      body: {
        "address": spersistence.walletAddress.val,
        "path": path,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.error}');
    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    return Right(ListObjectsResponse.fromJson(response.data));
  }

  Future<Either<Object?, ServerResponse>> deleteObjects(
      List<String> objects) async {
    // strip root address
    objects = objects
        .map(
          (e) => e.replaceAll('${spersistence.walletAddress.val}/', ''),
        )
        .toList();

    console.info('delete objects: $objects....');

    final response = await auth.client!.functions.invoke(
      kFunctionDeleteObjects,
      body: {
        "address": spersistence.walletAddress.val,
        "objects": objects,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.error}');
    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    return Right(ServerResponse.fromJson(response.data));
  }

  Future<Either<Object?, ListObjectsResponse>> deleteDirectory(
      String path) async {
    // strip root address
    path = path.replaceAll('${spersistence.walletAddress.val}/', '');
    console.info('delete directory: $path....');

    final response = await auth.client!.functions.invoke(
      kFunctionDeleteDirectory,
      body: {
        "address": spersistence.walletAddress.val,
        "path": path,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.error}');
    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    return Right(ListObjectsResponse.fromJson(response.data));
  }

  Future<Either<Object?, PresignUrlResponse>> presignUrl({
    required String object,
    String? address,
    String method = "GET",
    int expirySeconds = 1000,
  }) async {
    // strip root address
    object = object.replaceAll('${spersistence.walletAddress.val}/', '');
    console.info('presigning: $object....');

    final response = await auth.client!.functions.invoke(
      kFunctionPresignUrl,
      body: {
        "address": address ?? spersistence.walletAddress.val,
        "object": object,
        "method": method,
        "expirySeconds": expirySeconds,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.error}');
    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    return Right(PresignUrlResponse.fromJson(response.data));
  }

  Future<void> syncUser() async {
    if (await Purchases.isAnonymous) {
      return console.error('cannot sync anonymous user');
    }

    final objects = StorageService.to.rootInfo.value.data;

    final data = {
      "address": spersistence.walletAddress.val,
      "metadata": {
        'size': {
          'storage': objects.size,
          'vault': (await LisoManager.compactJson()).length,
        },
        'count': {
          'items': ItemsService.to.data.length,
          'groups': GroupsService.to.data.length,
          'categories': CategoriesService.to.data.length,
          'files': objects.count,
          'sharedVaults': SharedVaultsController.to.data.length,
          'joinedVaults': JoinedVaultsController.to.data.length,
        },
        'settings': {
          'sync': AppPersistence.to.sync.val,
          'theme': persistence.theme.val,
          'syncProvider': AppPersistence.to.newSyncProvider,
          'biometrics': persistence.biometrics.val,
          'analytics': persistence.analytics.val,
          'crashReporting': persistence.crashReporting.val,
          'backedUpSeed': AppPersistence.to.backedUpSeed.val,
          'backedUpPassword': AppPersistence.to.backedUpPassword.val,
          'localeCode': persistence.localeCode.val,
        }
      }
    };

    SupabaseFunctionsService.to.sync(data: data);
  }
}
