import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/models/config_web3.model.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:secrets/secrets.dart';

import '../../utils/globals.dart';
import 'models/config_app.model.dart';
import 'models/config_general.model.dart';
import 'models/config_limits.model.dart';
import 'models/config_s3.model.dart';
import 'models/config_users.model.dart';

class ConfigService extends GetxService with ConsoleMixin {
  static ConfigService get to => Get.find();

  // VARIABLES
  var general = const ConfigGeneral();
  var app = const ConfigApp();
  var s3 = const ConfigS3();
  var web3 = const ConfigWeb3();
  var limits = const ConfigLimits();
  var users = const ConfigUsers();

  // GETTERS
  FirebaseRemoteConfig get instance => FirebaseRemoteConfig.instance;
  String get appName => general.app.name;
  String get devName => general.developer.name;

  // INIT

  // FUNCTIONS
  Future<void> init() async {
    // pre-populate with local as defaults
    await _populate(local: true);
    if (!isFirebaseSupported) return console.warning('Not Supported');

    // SETTINGS
    await instance.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: 10.seconds,
      minimumFetchInterval: kDebugMode ? 0.seconds : 5.minutes,
    ));

    // workaround for https://github.com/firebase/flutterfire/issues/6196
    // Future.delayed(1.seconds).then((_) => fetch());
    fetch();
  }

  Future<void> fetch() async {
    if (!isFirebaseSupported) return console.warning('Not Supported');
    console.info('fetching...');

    try {
      final updated = await instance.fetchAndActivate();
      console.info('fetch updated: $updated');
      await _populate();
    } catch (e) {
      console.error('fetch error: $e');
    }
  }

  Future<void> _populate({bool local = false}) async {
    app = ConfigApp.fromJson(local
        ? Secrets.configs.app
        : jsonDecode(instance.getString('app_config')));

    s3 = ConfigS3.fromJson(local
        ? Secrets.configs.s3
        : jsonDecode(instance.getString('s3_config')));

    web3 = ConfigWeb3.fromJson(local
        ? Secrets.configs.web3
        : jsonDecode(instance.getString('web3_config')));

    limits = ConfigLimits.fromJson(local
        ? Secrets.configs.limits
        : jsonDecode(instance.getString('limits_config')));

    users = ConfigUsers.fromJson(local
        ? Secrets.configs.users
        : jsonDecode(instance.getString('users_config')));

    general = ConfigGeneral.fromJson(local
        ? Secrets.configs.general
        : jsonDecode(instance.getString('general_config')));

    console.info('populated! local: $local');
    // re-init s3 minio client
    S3Service.to.init();
  }
}
