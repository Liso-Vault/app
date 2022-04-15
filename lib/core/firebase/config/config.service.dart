import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';

import '../../../features/s3/s3.service.dart';
import 'models/config_client.model.dart';
import 'models/config_global.model.dart';
import 'models/config_s3.model.dart';

class ConfigService extends GetxService with ConsoleMixin {
  static ConfigService get to => Get.find();

  // VARIABLES
  var global = const ConfigGlobal();
  var client = const ConfigClient();
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

  // FUNCTIONS

  void _init() async {
    // SETTINGS
    await FirebaseRemoteConfig.instance.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: 10.seconds,
      minimumFetchInterval: kDebugMode ? 0.seconds : 2.hours,
    ));

    // DEFAULTS
    await instance.setDefaults({
      "global_config": (const ConfigGlobal()).toJsonString(),
      "client_config": (const ConfigClient()).toJsonString(),
      "s3_config": (const ConfigS3()).toJsonString(),
    });

    _populate();
    fetch();
  }

  void _populate() {
    global = ConfigGlobal.fromJson(
      jsonDecode(instance.getString("global_config")),
    );

    client = ConfigClient.fromJson(
      jsonDecode(instance.getString("client_config")),
    );

    s3 = ConfigS3.fromJson(
      jsonDecode(instance.getString("s3_config")),
    );

    S3Service.to.init();
  }

  Future<void> fetch() async {
    console.info('fetching...');

    try {
      final updated = await instance.fetchAndActivate();
      console.info('fetched! updated: $updated');
      _populate();
    } catch (e) {
      console.error('error: $e');
    }
  }
}
