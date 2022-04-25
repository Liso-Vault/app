import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/globals.dart';
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
  final attemptsLeft = PersistenceService.to.maxUnlockAttempts.val.obs;
  final busyMessage = ''.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    if (newState != null) busyMessage.value = newState;
    super.change(newState, status: status);
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
    if (status == RxStatus.loading()) return console.error('still busy');
    change('Exporting...', status: RxStatus.loading());

    await HiveManager.closeBoxes();
    final encoder = ZipFileEncoder();

    try {
      encoder.create(LisoManager.exportVaultFilePath);
      await encoder.addDirectory(Directory(LisoManager.hivePath));
      encoder.close();
    } catch (e) {
      await HiveManager.openBoxes();
      UIUtils.showSimpleDialog('File System Error', e.toString());
      return change(null, status: RxStatus.success());
    }

    await HiveManager.openBoxes();
    final tempVaultFile = File(LisoManager.exportVaultFilePath);
    console.info('path: ${tempVaultFile.path}');

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [tempVaultFile.path],
        subject: LisoManager.vaultFilename,
        text: GetPlatform.isIOS ? null : 'Liso Vault',
      );

      console.info('done');
      // tempVaultFile.delete();
      return _done();
    }

    change('Choose export path...', status: RxStatus.loading());
    Globals.timeLockEnabled = false; // temporarily disable
    // choose directory and export file
    final exportPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Export Path',
    );

    Globals.timeLockEnabled = true; // re-enable
    // user cancelled picker
    if (exportPath == null) {
      return change(null, status: RxStatus.success());
    }

    console.info('export path: $exportPath');
    change('Exporting to: $exportPath', status: RxStatus.loading());
    await Future.delayed(1.seconds); // just for style

    await FileUtils.move(
      tempVaultFile,
      join(exportPath, LisoManager.vaultFilename),
    );

    NotificationsManager.notify(
      title: 'Successfully Exported Vault',
      body: LisoManager.vaultFilename,
    );

    _done();
  }

  void _done() {
    change(null, status: RxStatus.success());
    Get.back();
  }
}
