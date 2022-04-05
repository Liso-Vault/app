import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web3dart/web3dart.dart';

import '../../core/liso/liso.manager.dart';
import '../../core/liso/liso_paths.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/isolates.dart';
import '../app/routes.dart';

class ExportScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExportScreenController());
  }
}

class ExportScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final passwordController = TextEditingController();

  // PROPERTIES
  final attemptsLeft = PersistenceController.to.maxUnlockAttempts.val.obs;
  final canProceed = false.obs;
  final busyMessage = ''.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void onChanged(String text) => canProceed.value = text.isNotEmpty;

  void unlock() async {
    if (GetPlatform.isAndroid) {
      final storagePermissionGranted =
          await Permission.storage.request().isGranted;

      if (!storagePermissionGranted) {
        UIUtils.showSnackBar(
          title: 'Storage Permission Denied',
          message: "Please allow manage storage permission to enable exporting",
          icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
          seconds: 4,
        );

        return;
      }
    }

    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());
    busyMessage.value = 'Verifying...';

    final masterWalletFilePath =
        '${LisoPaths.main!.path}/$kLocalMasterWalletFileName';

    // this is just to unlock the local master wallet
    Wallet? unlockedMasterWallet;

    try {
      unlockedMasterWallet = await compute(Isolates.loadWallet, {
        'file_path': masterWalletFilePath,
        'password': passwordController.text,
      });
    } catch (e) {
      change(null, status: RxStatus.success());
      console.error('load wallet failed: ${e.toString()}');

      attemptsLeft.value--;
      passwordController.clear();
      canProceed.value = false;

      if (attemptsLeft() <= 0) {
        LisoManager.reset();
        Get.offNamedUntil(Routes.main, (route) => false);
        return;
      }

      UIUtils.showSnackBar(
        title: 'Incorrect password',
        message:
            '${attemptsLeft.value} attempts left until your $kAppName resets',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return console.error('incorrect password');
    }

    busyMessage.value = 'Choose export path...';

    timeLockEnabled = false; // temporarily disable
    // choose directory and export file
    String? exportPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Export Path',
    );

    timeLockEnabled = true; // re-enable

    // user cancelled picker
    if (exportPath == null) {
      change(null, status: RxStatus.success());
      return;
    }

    console.info('export path: $exportPath');
    busyMessage.value = 'Exporting...';

    final walletAddress = unlockedMasterWallet!.privateKey.address.hexEip55;
    final exportFileName = '$walletAddress.liso';
    final exportFilePath = '$exportPath/$exportFileName';

    final encoder = ZipFileEncoder();
    encoder.create(exportFilePath);
    encoder.addDirectory(Directory(LisoPaths.hive!.path));
    encoder.close();

    NotificationsManager.notify(
      title: 'Successfully Exported Vault',
      body: exportFilePath,
    );

    console.info('exported: $exportFilePath');
    busyMessage.value = '';
    change(null, status: RxStatus.success());
    Get.back();
  }
}
