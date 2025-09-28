import 'dart:async';

import 'package:app_core/globals.dart';
import 'package:app_core/hive/models/device.hive.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DevicesScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static DevicesScreenController get to => Get.find();

  // VARIABLES
  StreamSubscription? _stream;
  final enforce = gParameters['enforce'] == 'true';

  // PROPERTIES
  final data = <HiveMetadataDevice>[].obs;

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    start();
    super.onInit();
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }

  // FUNCTIONS
  void restart() async {
    await stop();
    start();
    console.info('restarted');
  }

  Future<void> stop() async {
    await _stream?.cancel();
    console.info('stopped');
  }

  void start() {
    // TODO: temporary
    // if (GetPlatform.isWindows) {
    //   // TODO: fetch user's devices via cloud functions REST API
    //   return console.warning('Not Supported');
    // }

    // _stream = FirestoreService.to.userDevices
    //     .snapshots()
    //     .listen(_onData, onError: _onError);

    // console.info('started');
  }

  // void _onData(QuerySnapshot<HiveMetadataDevice>? snapshot) {
  //   if (snapshot == null || snapshot.docs.isEmpty) {
  //     change(null, status: RxStatus.empty());
  //     return data.clear();
  //   }

  //   data.value = snapshot.docs.map((e) => e.data()).toList();

  //   final thisDevice = Globals.metadata!.device;
  //   final foundDevices = data.where((e) => e.id == thisDevice.id);

  //   if (foundDevices.isEmpty) {
  //     data.add(thisDevice);
  //   }

  //   change(null, status: RxStatus.success());
  //   console.wtf('devices: ${data.length}');
  // }

  // void _onError(error) {
  //   console.error('stream error: $error');
  //   change(null, status: RxStatus.error('Failed to load: $error'));
  // }

  void unsync(HiveMetadataDevice device) {
    void confirm() async {
      // TODO: temporary
      // await FirestoreService.to.userDevices.doc(device.docId).delete();
      // data.remove(device);
      // Get.backLegacy(); // close dialog

      // if (enforce && data.length <= limits.devices) {
      //   Get.backLegacy(); // close screen
      // }
    }

    final dialogContent = Text(
      'Are you sure you want to unsync the device "${device.model} - ${device.id}"?',
    );

    Get.dialog(AlertDialog(
      title: Text('unsync_device'.tr),
      content: isSmallScreen
          ? dialogContent
          : SizedBox(
              width: 450,
              child: dialogContent,
            ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: confirm,
          child: Text('unsync'.tr),
        ),
      ],
    ));
  }
}
