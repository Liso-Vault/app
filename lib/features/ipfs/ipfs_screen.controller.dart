import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/features/ipfs/ipfs.service.dart';
import 'package:console_mixin/console_mixin.dart';

import '../../core/utils/ui_utils.dart';

class IPFSScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IPFSScreenController());
  }
}

class IPFSScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final ipfsUrlController = TextEditingController();
  final persistence = Get.find<PersistenceService>();

  // PROPERTIES
  final protocol = ''.obs;
  final ipfsBusy = false.obs;

  @override
  void onInit() {
    change(null, status: RxStatus.success());
    ipfsUrlController.text = persistence.ipfsServerUrl;
    super.onInit();
  }

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void save() async {
    if (!formKey.currentState!.validate()) return;
    final uri = Uri.parse(ipfsUrlController.text);

    // save to persistence
    persistence.ipfsScheme.val = uri.scheme;
    persistence.ipfsHost.val = uri.host;
    persistence.ipfsPort.val = uri.port;

    // Get.create reinitializes! Fix this first
    // SettingsScreenController.to.ipfsServerUrl.value = urlController.text;

    // re-initialize
    await IPFSService.to.init();

    if (persistence.ipfsSync.val) {
      change(null, status: RxStatus.loading());
      await IPFSService.to.sync();
      change(null, status: RxStatus.success());
    }

    Get.back();
  }

  Future<bool> checkIPFS({bool showSuccess = true}) async {
    ipfsBusy.value = true;

    final uri = Uri.tryParse(ipfsUrlController.text);
    if (uri == null) return false;

    // save to persistence
    final persistence = Get.find<PersistenceService>();
    persistence.ipfsScheme.val = uri.scheme;
    persistence.ipfsHost.val = uri.host;
    persistence.ipfsPort.val = uri.port;

    final connected = await IPFSService.to.init();
    ipfsBusy.value = false;

    if (!connected) {
      UIUtils.showSimpleDialog(
        'IPFS Connection Failed',
        'Failed to connect to: ${ipfsUrlController.text}\nDouble check the Server URL and make sure your IPFS Node is up and running',
      );
    } else if (showSuccess) {
      UIUtils.showSimpleDialog(
        'IPFS Connection Success',
        'Successfully connects to your server: ${ipfsUrlController.text}\nYou\'re now ready to sync.',
      );
    }

    return connected;
  }
}
