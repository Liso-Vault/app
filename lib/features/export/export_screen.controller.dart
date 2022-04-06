import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/liso/liso_paths.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
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
  final busyMessage = ''.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void unlock() async {
    // prompt password from unlock screen
    final unlocked = await Get.toNamed(
          Routes.unlock,
          parameters: {'mode': 'password_prompt'},
        ) ??
        false;

    if (!unlocked) return;

    // if (GetPlatform.isAndroid) {
    //   final storagePermissionGranted =
    //       await Permission.storage.request().isGranted;

    //   if (!storagePermissionGranted) {
    //     UIUtils.showSimpleDialog(
    //       'Storage Permission Denied',
    //       "Please allow manage storage permission to enable exporting",
    //     );

    //     return;
    //   }
    // }

    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());
    busyMessage.value = 'Exporting...';

    final walletAddress = masterWallet!.privateKey.address.hexEip55;
    final archiveFileName = '$walletAddress.liso';

    final encoder = ZipFileEncoder();
    final archiveFilePath = join(LisoPaths.temp!.path, archiveFileName);

    try {
      encoder.create(archiveFilePath);
      await encoder.addDirectory(Directory(LisoPaths.hive!.path));
      encoder.close();
    } catch (e) {
      UIUtils.showSimpleDialog('File System Error', e.toString());
      return change(null, status: RxStatus.success());
    }

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [archiveFilePath],
        subject: archiveFileName,
        text: 'Liso Vault',
      );

      return _done();
    }

    busyMessage.value = 'Choose export path...';

    timeLockEnabled = false; // temporarily disable
    // choose directory and export file
    final exportPath = await FilePicker.platform
        .getDirectoryPath(dialogTitle: 'Choose Export Path');
    timeLockEnabled = true; // re-enable
    // user cancelled picker
    if (exportPath == null) {
      return change(null, status: RxStatus.success());
    }

    console.info('export path: $exportPath');
    busyMessage.value = 'Exporting to: $exportPath';
    await Future.delayed(1.seconds); // just for style

    final exportedFile = await Utils.moveFile(
      File(archiveFilePath),
      join(exportPath, archiveFileName),
    );

    NotificationsManager.notify(
      title: 'Successfully Exported Vault',
      body: exportedFile.path,
    );

    _done();
  }

  void _done() {
    busyMessage.value = '';
    change(null, status: RxStatus.success());
    Get.back();
  }
}
