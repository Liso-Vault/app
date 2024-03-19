import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/supabase/model/server_response.model.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:app_core/supabase/supabase_functions.service.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:secrets/secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/persistence/persistence.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/services/global.service.dart';
import '../categories/categories.service.dart';
import '../files/storage.service.dart';
import '../groups/groups.service.dart';
import '../items/items.service.dart';
import '../joined_vaults/joined_vault.controller.dart';
import '../shared_vaults/shared_vault.controller.dart';
import 'model/error_response.model.dart';
import 'model/list_objects_response.model.dart';
import 'model/presign_response.model.dart';
import 'model/stat_response.model.dart';
import 'model/status.model.dart';

class AppFunctionsService extends FunctionsService {
  static AppFunctionsService get to => Get.find();

  // VARIABLES
  final persistence = Get.find<Persistence>();

  // PROPERTIES
  final ready = false.obs;
  final busy = false.obs;

  // GETTERS

  // INIT

  // FUNCTIONS

  Future<Either<ErrorResponse, Status>> status({bool force = false}) async {
    if (!AuthService.to.authenticated) {
      return const Left(
        ErrorResponse(
          error: ErrorData(message: 'unauthenticated'),
        ),
      );
    }

    // console.info('status...');
    FunctionResponse? response;

    try {
      response = await FunctionsService.to.functions.invoke(
        'status',
        body: {'force': force},
      );
    } catch (e) {
      final message = 'status() invoke error: $e';
      console.error(message);
      return Left(ErrorResponse(error: ErrorData(message: message)));
    }

    // server error
    if (response.status != 200) {
      console.error(
        'status() response error: ${response.status}: ${response.data}',
      );

      return Left(ErrorResponse.fromJson(response.data));
    }

    final serverResponse = ServerResponse.fromJson(response.data);

    // openai error
    if (serverResponse.errors.isNotEmpty) {
      for (var e in serverResponse.errors) {
        console.error('status() server error: ${e.toJson()}');
      }

      final error = serverResponse.errors.first;

      return Left(
        ErrorResponse(
          error: ErrorData(
            code: error.code.toString(),
            message: error.message ?? 'Unknown Error',
          ),
        ),
      );
    }

    final responseObject = Status.fromJson(serverResponse.data);
    // console.wtf('status: ${responseObject.toJson()}');
    GlobalService.to.userStatus.value = responseObject;
    ready.value = true;
    return Right(responseObject);
  }

  Future<Either<Object?, StatObjectResponse>> statObject(
    String object, {
    String? address,
  }) async {
    // strip root address
    object = object.replaceAll(
      '${SecretPersistence.to.walletAddress.val}/',
      '',
    );

    // console.info(
    //     'stat: $object.... $address | ${SecretPersistence.to.walletAddress.val}');

    final response = await functions.invoke(
      kFunctionStatObject,
      body: {
        "address": address ?? SecretPersistence.to.walletAddress.val,
        "object": object,
      },
    );

    // console.debug('raw: ${response.data}, errors: ${response.status}');

    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    return Right(StatObjectResponse.fromJson(response.data));
  }

  Future<Either<Object?, ListObjectsResponse>> listObjects({
    String path = '',
  }) async {
    // strip root address
    path = path.replaceAll('${SecretPersistence.to.walletAddress.val}/', '');
    // console.info('list objects: $path....');

    final response = await functions.invoke(
      kFunctionListObjects,
      body: {
        "address": SecretPersistence.to.walletAddress.val,
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
          (e) => e.replaceAll('${SecretPersistence.to.walletAddress.val}/', ''),
        )
        .toList();

    // console.info('delete objects: $objects....');

    final response = await functions.invoke(
      kFunctionDeleteObjects,
      body: {
        "address": SecretPersistence.to.walletAddress.val,
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
    path = path.replaceAll('${SecretPersistence.to.walletAddress.val}/', '');
    // console.info('delete directory: $path....');

    final response = await functions.invoke(
      kFunctionDeleteDirectory,
      body: {
        "address": SecretPersistence.to.walletAddress.val,
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
    object = object.replaceAll(
      '${SecretPersistence.to.walletAddress.val}/',
      '',
    );
    // console.info('presigning: $object.... $address');

    final response = await functions.invoke(
      kFunctionPresignUrl,
      body: {
        "address": address ?? SecretPersistence.to.walletAddress.val,
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

    final objects = FileService.to.rootInfo.value.data;

    final data = {
      "address": SecretPersistence.to.walletAddress.val,
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

    FunctionsService.to.sync(AuthService.to.user!, data: data);
  }
}
