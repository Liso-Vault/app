import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:secrets/secrets.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/persistence/persistence.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/services/cipher.service.dart';
import '../../core/utils/globals.dart';
import '../categories/categories.service.dart';
import '../files/storage.service.dart';
import '../groups/groups.service.dart';
import '../items/items.service.dart';
import '../joined_vaults/joined_vault.controller.dart';
import '../pro/pro.controller.dart';
import '../shared_vaults/shared_vault.controller.dart';
import 'model/entitlement_response.model.dart';
import 'model/gumroad_product.model.dart';
import 'model/list_objects_response.model.dart';
import 'model/presign_response.model.dart';
import 'model/server_response.model.dart';
import 'model/stat_response.model.dart';
import 'model/sync_user_response.model.dart';
import 'supabase_auth.service.dart';

class SupabaseFunctionsService extends GetxService with ConsoleMixin {
  static SupabaseFunctionsService get to => Get.find();

  // VARIABLES
  final auth = Get.find<SupabaseAuthService>();
  final config = Get.find<ConfigService>();
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

    // console.debug('raw: ${response.data}, errors: ${response.error}');
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

  Future<void> sync() async {
    if (!auth.authenticated) return console.warning('not authenticated');
    console.info('sync...');

    // calculate vault byte size
    final encryptedVaultBytes = CipherService.to.encrypt(
      utf8.encode(await LisoManager.compactJson()),
    );

    final storage = Get.find<StorageService>();
    final data = storage.rootInfo.value.data;

    final response = await auth.client!.functions.invoke(
      'sync-user',
      body: {
        if (isIAPSupported) ...{
          "rcUserId": await Purchases.appUserID,
        },
        "email": auth.user?.email,
        "phone": auth.user?.phone,
        "address": spersistence.walletAddress.val,
        "userMetadata": auth.user?.userMetadata,
        "metadata": {
          'size': {
            'storage': data.size,
            'vault': encryptedVaultBytes.length,
          },
          'count': {
            'items': ItemsService.to.data.length,
            'groups': GroupsService.to.data.length,
            'categories': CategoriesService.to.data.length,
            'files': data.count,
            'sharedVaults': SharedVaultsController.to.data.length,
            'joinedVaults': JoinedVaultsController.to.data.length,
          },
          'settings': {
            'sync': persistence.sync.val,
            'theme': persistence.theme.val,
            'syncProvider': persistence.newSyncProvider,
            'biometrics': persistence.biometrics.val,
            'analytics': persistence.analytics.val,
            'crashReporting': persistence.crashReporting.val,
            'backedUpSeed': persistence.backedUpSeed.val,
            'backedUpPassword': persistence.backedUpPassword.val,
            'localeCode': persistence.localeCode.val,
          }
        },
        "device": Globals.metadata!.device.toJson()
      },
    );

    if (response.status != 200) {
      return console.error(
        'supabase error: ${response.status}: ${response.data}',
      );
    }

    final serverResponse = ServerResponse.fromJson(response.data);

    if (serverResponse.errors.isNotEmpty) {
      return console.error('server error: ${serverResponse.errors}');
    }

    // console.wtf('synced: ${jsonEncode(serverResponse.toJson())}');
    final syncUserResponse = SyncUserResponse.fromJson(serverResponse.data);
    ProController.to.licenseKey.value = syncUserResponse.licenseKey;

    // VERIFY PRO
    if (ProController.to.proEntitlement?.isActive != true) {
      if (syncUserResponse.licenseKey.length >= 35) {
        verifyGumroad(syncUserResponse.licenseKey);
      } else if (syncUserResponse.rcUserId.isNotEmpty && !isIAPSupported) {
        verifyRevenueCat(syncUserResponse.rcUserId);
      } else {
        ProController.to.verifiedPro.value = false;
      }
    }
  }

  Future<Either<String, GumroadProduct>> gumroadProductDetail() async {
    console.info('gumroadProductDetail...');

    final response = await auth.client!.functions.invoke(
      'gumroad-product-detail',
      body: {"localeCode": Get.locale?.languageCode},
    );

    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    final serverResponse = ServerResponse.fromJson(response.data);

    if (serverResponse.errors.isNotEmpty) {
      String errors = '';

      for (var e in serverResponse.errors) {
        errors += '${e.code}: ${e.message}';
      }

      console.error('server error: $errors');
      return Left(errors);
    }

    final product = GumroadProduct.fromJson(serverResponse.data);
    console.info('product: ${jsonEncode(product.toJson())}');
    return Right(product);
  }

  Future<Either<String, EntitlementResponse>> verifyGumroad(String licenseKey,
      {bool updateEntitlement = true}) async {
    if (!auth.authenticated) {
      console.warning('not authenticated');
      return const Left('Please sign in to continue');
    }

    console.info('verifyGumroad...');

    final response = await auth.client!.functions.invoke(
      'verify-gumroad',
      body: {"licenseKey": licenseKey},
    );

    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    final serverResponse = ServerResponse.fromJson(response.data);

    if (serverResponse.errors.isNotEmpty) {
      String errors = '';

      for (var e in serverResponse.errors) {
        errors += '${e.code}: ${e.message}';
      }

      console.error('server error: $errors');
      ProController.to.verifiedPro.value = false;
      return Left(errors);
    }

    final entitlement = EntitlementResponse.fromJson(serverResponse.data);
    console.info('entitlement: ${jsonEncode(entitlement.toJson())}');

    if (updateEntitlement) {
      ProController.to.verifiedPro.value = entitlement.entitled;
      if (entitlement.entitled) console.wtf('PRO ENTITLED');
    }

    return Right(entitlement);
  }

  Future<Either<String, EntitlementResponse>> verifyRevenueCat(String rcUserId,
      {bool updateEntitlement = true}) async {
    if (!auth.authenticated) {
      console.warning('not authenticated');
      return const Left('Please sign in to continue');
    }

    console.info('verifyRevenueCat...');

    final response = await auth.client!.functions.invoke(
      'verify-revenuecat',
      body: {"userId": rcUserId},
    );

    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    final serverResponse = ServerResponse.fromJson(response.data);

    if (serverResponse.errors.isNotEmpty) {
      String errors = '';

      for (var e in serverResponse.errors) {
        errors += '${e.code}: ${e.message}';
      }

      console.error('server error: $errors');
      ProController.to.verifiedPro.value = false;
      return Left(errors);
    }

    final entitlement = EntitlementResponse.fromJson(serverResponse.data);
    console.wtf('entitlement: ${jsonEncode(entitlement.toJson())}');

    if (updateEntitlement) {
      ProController.to.verifiedPro.value = entitlement.entitled;
      if (entitlement.entitled) console.wtf('PRO ENTITLED');
    }

    return Right(entitlement);
  }
}
