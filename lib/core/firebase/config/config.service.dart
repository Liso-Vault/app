import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/data/app_config.json.dart';
import 'package:liso/core/firebase/config/data/general_config.json.dart';
import 'package:liso/core/utils/console.dart';

import 'data/s3_config.json.dart';
import 'models/config_app.model.dart';
import 'models/config_global.model.dart';
import 'models/config_s3.model.dart';

class ConfigService extends GetxService with ConsoleMixin {
  static ConfigService get to => Get.find();

  // VARIABLES
  var general = const ConfigGeneral();
  var app = const ConfigApp();
  var s3 = const ConfigS3();

  // GETTERS
  FirebaseRemoteConfig get instance => FirebaseRemoteConfig.instance;

  // INIT
  @override
  void onInit() {
    _init();
    console.info('onInit');
    super.onInit();
  }

  // GETTERS

  String get appName => general.app.name;
  String get devName => general.developer.name;

  // FUNCTIONS

  void _init() async {
    // SETTINGS
    await instance.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: 10.seconds,
      minimumFetchInterval: kDebugMode ? 0.seconds : 2.hours,
    ));

    // DEFAULTS

    await instance.setDefaults({
      "general_config": jsonEncode(kConfigGeneralMap),
      "app_config": jsonEncode(kConfigAppMap),
      "s3_config": jsonEncode(kConfigS3Map),
    });

    // pre-populate to make sure
    _populate();
    // workaround for https://github.com/firebase/flutterfire/issues/6196
    await Future.delayed(2.seconds);
    fetch();
  }

  void _populate() {
    general = ConfigGeneral.fromJson(
      jsonDecode(instance.getString("general_config")),
    );

    app = ConfigApp.fromJson(
      jsonDecode(instance.getString("app_config")),
    );

    s3 = ConfigS3.fromJson(
      jsonDecode(instance.getString("s3_config")),
    );
  }

  Future<void> fetch() async {
    console.info('fetching...');

    Future<void> _run() async {
      final updated = await instance.fetchAndActivate();
      console.info('fetched! updated: $updated');
      _populate();
    }

    try {
      await _run();
    } catch (e) {
      console.error('error: $e');
    }
  }
}
