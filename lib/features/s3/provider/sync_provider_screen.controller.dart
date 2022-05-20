import 'dart:async';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:minio/minio.dart';

import '../../../core/utils/globals.dart';
import '../../../core/utils/utils.dart';

class SyncProviderScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SyncProviderScreenController());
  }
}

class SyncProviderScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final persistence = Get.find<PersistenceService>();

  final endpointController = TextEditingController();
  final accessKeyController = TextEditingController();
  final secretKeyController = TextEditingController();
  final bucketController = TextEditingController();
  final portController = TextEditingController();
  final regionController = TextEditingController();
  final sessionTokenController = TextEditingController();

  // PROPERTIES
  final busy = false.obs;

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());

    // Populate from persistence
    endpointController.text = persistence.s3Endpoint.val;
    accessKeyController.text = persistence.s3AccessKey.val;
    secretKeyController.text = persistence.s3SecretKey.val;
    bucketController.text = persistence.s3Bucket.val;
    portController.text = persistence.s3Port.val;
    regionController.text = persistence.s3Region.val;
    sessionTokenController.text = persistence.s3SessionToken.val;

    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  void save() {
    persistence.syncProvider.val = LisoSyncProvider.custom.name;

    persistence.s3Endpoint.val = endpointController.text;
    persistence.s3AccessKey.val = accessKeyController.text;
    persistence.s3SecretKey.val = secretKeyController.text;
    persistence.s3Bucket.val = bucketController.text;
    persistence.s3Port.val = portController.text;
    persistence.s3Region.val = regionController.text;
    persistence.s3SessionToken.val = sessionTokenController.text;

    S3Service.to.init();
    Get.close(2);
  }

  void testConnection() async {
    if (!formKey.currentState!.validate()) return;
    if (busy.value) return console.error('still busy');
    change(null, status: RxStatus.loading());

    final client = Minio(
      endPoint: endpointController.text,
      accessKey: accessKeyController.text,
      secretKey: secretKeyController.text,
      port: int.tryParse(portController.text),
      region: regionController.text.isEmpty ? null : regionController.text,
      sessionToken: sessionTokenController.text.isEmpty
          ? null
          : sessionTokenController.text,
      enableTrace: persistence.s3EnableTrace.val,
      useSSL: persistence.s3UseSsl.val,
    );

    bool bucketExists = false;

    try {
      bucketExists = await client
          .bucketExists(
            bucketController.text,
          )
          .timeout(10.seconds);
      change(null, status: RxStatus.success());
    } on TimeoutException {
      change(null, status: RxStatus.success());
      return UIUtils.showSimpleDialog(
        'Connection Timed Out',
        'Please check your configuration and your network',
      );
    } catch (e) {
      change(null, status: RxStatus.success());
      console.error(e.toString());

      return UIUtils.showSimpleDialog(
        'Connection Error',
        e.toString(),
      );
    }

    if (bucketExists) {
      const dialogContent = Text('Configuration is ready to be used');

      Get.dialog(AlertDialog(
        title: const Text('Connection Success'),
        content: Utils.isDrawerExpandable
            ? dialogContent
            : const SizedBox(width: 600, child: dialogContent),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: save,
            child: const Text('Use Configuration'),
          ),
        ],
      ));
    } else {
      UIUtils.showSimpleDialog(
        'Connection Failed',
        'Bucket: ${bucketController.text} is not found',
      );
    }
  }
}
