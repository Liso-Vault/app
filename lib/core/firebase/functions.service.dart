import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/models/config_root.model.dart';
import 'package:liso/core/firebase/model/user.model.dart';
import 'package:liso/core/hive/models/metadata/device.hive.dart';

import '../utils/globals.dart';

class FunctionsService extends GetxService with ConsoleMixin {
  static FunctionsService get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // GETTERS
  FirebaseFunctions get instance => FirebaseFunctions.instance;

  // INIT
  @override
  void onInit() {
    if (kUseFirebaseEmulator) {
      instance.useFunctionsEmulator(kFirebaseHost, kFirebasePort);
    }

    super.onInit();
  }

  // FUNCTIONS

  Future<Either<String, ConfigRoot>> getRemoteConfig() async {
    console.debug('fetching...');
    HttpsCallableResult? result;

    try {
      result = await FirebaseFunctions.instance
          .httpsCallable('getRemoteConfig')
          .call();
    } on FirebaseFunctionsException catch (e) {
      return Left('error fetching remote config: $e');
    }

    if (result.data == false) {
      return const Left('failed to fetch remote config');
    }

    // console.wtf('response: ${result.data}');
    return Right(ConfigRoot.fromJson(jsonDecode(result.data)));
  }

  Future<Either<String, FirebaseUser>> getUser(String userId) async {
    console.debug('fetching...');
    HttpsCallableResult? result;

    try {
      result = await FirebaseFunctions.instance
          .httpsCallable('getUser')
          .call({'userId': userId});
    } on FirebaseFunctionsException catch (e) {
      return Left('error fetching user: $e');
    }

    if (result.data == false) {
      return const Left('failed to get user');
    }

    // console.wtf('${result.data}');
    return Right(FirebaseUser.fromFunctionsJson(jsonDecode(result.data)));
  }

  Future<Either<String, bool>> setUser(
    FirebaseUser user,
    HiveMetadataDevice device,
  ) async {
    console.debug('setting...');
    HttpsCallableResult? result;

    try {
      result = await FirebaseFunctions.instance.httpsCallable('setUser').call({
        'user': user.toFunctionsJson(),
        'device': device.toJson(),
      });
    } on FirebaseFunctionsException catch (e) {
      return Left('error setting user: $e');
    }

    if (result.data != true) {
      return const Left('failed to set user');
    }

    return Right(result.data);
  }
}
