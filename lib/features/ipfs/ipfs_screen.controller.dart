import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/services/ipfs.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/ui_utils.dart';

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
  final urlController = TextEditingController();
  final persistence = Get.find<PersistenceController>();

  // PROPERTIES
  final protocol = ''.obs;

  @override
  void onInit() {
    change(null, status: RxStatus.success());
    urlController.text = persistence.ipfsServerUrl;
    super.onInit();
  }

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void save() async {
    if (!formKey.currentState!.validate()) return;
    final uri = Uri.tryParse(urlController.text);

    if (uri == null) {
      return UIUtils.showSimpleDialog(
        'Invalid Server URL',
        'Please enter a valid IPFS Server URL',
      );
    }

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

  String? validateUri(String data) {
    final uri = Uri.tryParse(data);

    if (uri != null &&
        !uri.hasQuery &&
        uri.hasEmptyPath &&
        uri.hasPort &&
        uri.host.isNotEmpty) {
      return null;
    }

    return 'Invalid Server URL';
  }
}
