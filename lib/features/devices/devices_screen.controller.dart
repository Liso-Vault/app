import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/hive/models/metadata/device.hive.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/utils/utils.dart';
import '../wallet/wallet.service.dart';

class DevicesScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DevicesScreenController(), fenix: true);
  }
}

class DevicesScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static DevicesScreenController get to => Get.find();

  // VARIABLES
  final enforce = Get.parameters['enforce'] == 'true';

  // PROPERTIES
  final data = <HiveMetadataDevice>[].obs;

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    load();
    super.onInit();
  }

  // FUNCTIONS
  void load() async {
    change(null, status: RxStatus.loading());
    final snapshot = await FirestoreService.to.userDevices.get();
    data.value = snapshot.docs.map((e) => e.data()).toList();

    final thisDevice = Globals.metadata.device;
    final foundDevices = data.where((e) => e.id == thisDevice.id);

    if (foundDevices.isEmpty) {
      data.add(thisDevice);
    }

    change(null, status: RxStatus.success());
  }

  void unsync(HiveMetadataDevice device) {
    void _unsync() async {
      await FirestoreService.to.userDevices.doc(device.docId).delete();
      data.remove(device);
      Get.back(); // close dialog

      if (enforce && data.length <= WalletService.to.limits.devices) {
        Get.back(); // close screen
      }
    }

    final dialogContent = Text(
      'Are you sure you want to unsync the device "${device.model} - ${device.id}"?',
    );

    Get.dialog(AlertDialog(
      title: Text('unsync_device'.tr),
      content: Utils.isDrawerExpandable
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
          onPressed: _unsync,
          child: Text('unsync'.tr),
        ),
      ],
    ));
  }
}
