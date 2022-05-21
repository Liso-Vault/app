import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/hive/hive.manager.dart';
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

    final dateFormat = DateFormat('MMM-dd-yyyy_hh-mm_aaa');
    final exportFileName =
        '${WalletService.to.longAddress}-${dateFormat.format(DateTime.now())}.$kVaultExtension';

    final vaultFile = await HiveManager.export(
      path: join(LisoPaths.tempPath, exportFileName),
    );

    console.info('vault file path: ${vaultFile.path}');

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [vaultFile.path],
        subject: exportFileName,
        text: GetPlatform.isIOS ? null : '${ConfigService.to.appName} Vault',
      );

      console.info('done');
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
    await FileUtils.move(vaultFile, join(exportPath, exportFileName));
    NotificationsManager.notify(title: 'Exported Vault', body: exportFileName);

    _done();
  }

  void _done() {
    change(null, status: RxStatus.success());
    Get.back();
  }
}
