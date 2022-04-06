import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/liso/liso_paths.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';

class SettingsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsScreenController());
  }
}

class SettingsScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  // VARIABLES

  // PROPERTIES
  final busyMessage = ''.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void exportWallet() async {
    // prompt password from unlock screen
    final unlocked = await Get.toNamed(
          Routes.unlock,
          parameters: {'mode': 'password_prompt'},
        ) ??
        false;

    if (!unlocked) return;

    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());
    busyMessage.value = 'Exporting...';

    final file = File('${LisoPaths.main!.path}/$kLocalMasterWalletFileName');

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [file.path],
        subject: kLocalMasterWalletFileName,
        text: 'Liso Wallet',
      );

      return Get.back();
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
      file,
      join(exportPath, kLocalMasterWalletFileName),
    );

    NotificationsManager.notify(
      title: 'Successfully Exported Wallet',
      body: exportedFile.path,
    );

    Get.back();
  }
}
