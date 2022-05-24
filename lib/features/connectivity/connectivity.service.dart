import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'package:console_mixin/console_mixin.dart';

class ConnectivityService extends GetxService with ConsoleMixin {
  static ConnectivityService get to => Get.find();

  // VARIABLES
  StreamSubscription<ConnectivityResult>? connectivitySubscription;

  // PROPERTIES
  final connected = true.obs;

  // GETTERS

  // INIT
  @override
  void onInit() async {
    final connectivity = Connectivity();

    // get current status
    connected.value =
        await connectivity.checkConnectivity() != ConnectivityResult.none;
    console.info('connected: ${connected.value}');

    // stream subscription
    connectivitySubscription =
        connectivity.onConnectivityChanged.listen((result) {
      connected.value = result != ConnectivityResult.none;
      console.info('connected: ${connected()}');
    });

    super.onInit();
  }

  // FUNCTIONS
  void cancel() => connectivitySubscription?.cancel();
}
