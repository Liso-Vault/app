import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/notifications/notifications.manager.dart';
import '../app/routes.dart';
import '../menu/menu.item.dart';

class SettingsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsScreenController());
  }
}

class SettingsScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static SettingsScreenController get to => Get.find();

  // VARIABLES
  List<ContextMenuItem> get menuItemsTheme {
    return [
      ContextMenuItem(
        title: ThemeMode.system.name.tr,
        leading: const Icon(LineIcons.microchip),
        onSelected: () => changeTheme(ThemeMode.system),
      ),
      ContextMenuItem(
        title: ThemeMode.dark.name.tr,
        leading: const Icon(LineIcons.moon),
        onSelected: () => changeTheme(ThemeMode.dark),
      ),
      ContextMenuItem(
        title: ThemeMode.light.name.tr,
        leading: const Icon(LineIcons.sun),
        onSelected: () => changeTheme(ThemeMode.light),
      ),
    ];
  }

  // PROPERTIES
  final busyMessage = ''.obs;
  final theme = PersistenceService.to.theme.val.obs;
  final ipfsServerUrl = ''.obs;

  // GETTERS
  bool get canExportVault =>
      HiveManager.items != null && HiveManager.items!.isNotEmpty;

  // INIT
  @override
  void onInit() {
    final persistence = Get.find<PersistenceService>();
    ipfsServerUrl.value =
        '${persistence.ipfsScheme.val}://${persistence.ipfsHost.val}:${persistence.ipfsPort.val}';
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    if (newState != null) busyMessage.value = newState;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  void changeTheme(ThemeMode mode) async {
    PersistenceService.to.theme.val = mode.name;
    theme.value = mode.name;
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
    change('Exporting...', status: RxStatus.loading());
    final file = File(LisoManager.walletFilePath);

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [file.path],
        subject: LisoManager.walletFileName,
        text: 'Liso Wallet',
      );

      return Get.back();
    }

    change('Choose export path...', status: RxStatus.loading());
    Globals.timeLockEnabled = false; // temporarily disable
    // choose directory and export file
    final exportPath = await FilePicker.platform
        .getDirectoryPath(dialogTitle: 'Choose Export Path');
    Globals.timeLockEnabled = true; // re-enable
    // user cancelled picker
    if (exportPath == null) {
      return change(null, status: RxStatus.success());
    }

    console.info('export path: $exportPath');
    change('Exporting to: $exportPath', status: RxStatus.loading());
    await Future.delayed(1.seconds); // just for style

    final exportFileName =
        '${LisoManager.walletAddress}.wallet.$kWalletExtension';

    file.copy(join(exportPath, exportFileName));

    NotificationsManager.notify(
      title: 'Successfully Exported Wallet',
      body: exportFileName,
    );

    Get.back();
  }

  void changePassword() {
    UIUtils.showSimpleDialog(
      'Change Password Instruction',
      'In order to change your wallet password, you are required to reset everything, re-import the vault, then you can set a new password. Make sure you have the master seed phrase and backed up the latest vault before proceeding.',
    );
  }
}
