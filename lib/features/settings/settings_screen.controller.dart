import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/liso/liso_paths.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../menu/context.menu.dart';
import '../menu/menu.item.dart';

class SettingsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsScreenController());
  }
}

class SettingsScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  // VARIABLES
  Offset? lastMousePosition;

  // PROPERTIES
  final busyMessage = ''.obs;
  final theme = PersistenceController.to.theme.val.obs;

  // GETTERS
  bool get canExportVault =>
      HiveManager.items != null && HiveManager.items!.isNotEmpty;

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void selectTheme() {
    final items = [
      ContextMenuItem(
        title: ThemeMode.system.name.tr,
        leading: const Icon(LineIcons.microchip),
        function: () => changeTheme(ThemeMode.system),
      ),
      ContextMenuItem(
        title: ThemeMode.dark.name.tr,
        leading: const Icon(LineIcons.moon),
        function: () => changeTheme(ThemeMode.dark),
      ),
      ContextMenuItem(
        title: ThemeMode.light.name.tr,
        leading: const Icon(LineIcons.sun),
        function: () => changeTheme(ThemeMode.light),
      ),
    ];

    ContextMenu(
      position: lastMousePosition,
      initialItem: items.firstWhere(
        (e) => e.title == PersistenceController.to.theme.val.tr,
      ),
      items: items,
    ).show();
  }

  void changeTheme(ThemeMode mode) {
    PersistenceController.to.theme.val = mode.name;
    Get.changeThemeMode(mode);
  }

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

    await Utils.moveFile(
      file,
      join(exportPath, kLocalMasterWalletFileName),
    );

    NotificationsManager.notify(
      title: 'Successfully Exported Wallet',
      body: kLocalMasterWalletFileName,
    );

    Get.back();
  }

  void changePassword() {
    Get.generalDialog(
      pageBuilder: (_, __, ___) => AlertDialog(
        title: const Text('Change Password Instruction'),
        content: const Text(
            'In order to change your wallet password, you are required to reset everything, re-import the vault, then you can set a new password. Make sure you have the master seed phrase and backed up the latest vault before proceeding.'),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: Get.back,
          ),
        ],
      ),
    );
  }
}
