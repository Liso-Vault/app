import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/hive/models/metadata/device.hive.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/utils/utils.dart';
import '../pro/pro.controller.dart';

class DevicesScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static DevicesScreenController get to => Get.find();

  // VARIABLES
  StreamSubscription? _stream;
  final enforce = Get.parameters['enforce'] == 'true';

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
    if (GetPlatform.isWindows) {
      // TODO: fetch user's devices via cloud functions REST API
      return console.warning('Not Supported');
    }

    _stream = FirestoreService.to.userDevices
        .snapshots()
        .listen(_onData, onError: _onError);

    console.info('started');
  }

  void _onData(QuerySnapshot<HiveMetadataDevice>? snapshot) {
    if (snapshot == null || snapshot.docs.isEmpty) {
      change(null, status: RxStatus.empty());
      return data.clear();
    }

    data.value = snapshot.docs.map((e) => e.data()).toList();

    final thisDevice = Globals.metadata!.device;
    final foundDevices = data.where((e) => e.id == thisDevice.id);

    if (foundDevices.isEmpty) {
      data.add(thisDevice);
    }

    change(null, status: RxStatus.success());
    console.wtf('devices: ${data.length}');
  }

  void _onError(error) {
    console.error('stream error: $error');
    change(null, status: RxStatus.error('Failed to load: $error'));
  }

  void unsync(HiveMetadataDevice device) {
    void confirm() async {
      await FirestoreService.to.userDevices.doc(device.docId).delete();
      data.remove(device);
      Get.back(); // close dialog

      if (enforce && data.length <= ProController.to.limits.devices) {
        Get.back(); // close screen
      }
    }

    final dialogContent = Text(
      'Are you sure you want to unsync the device "${device.model} - ${device.id}"?',
    );

    Get.dialog(AlertDialog(
      title: Text('unsync_device'.tr),
      content: Utils.isSmallScreen
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
