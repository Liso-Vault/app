import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/hive/hive_items.service.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/hive/hive_groups.service.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../menu/menu.item.dart';
import '../wallet/wallet.service.dart';

class SettingsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsScreenController(), fenix: true);
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
        leading: const Icon(Iconsax.cpu),
        onSelected: () => changeTheme(ThemeMode.system),
      ),
      ContextMenuItem(
        title: ThemeMode.dark.name.tr,
        leading: const Icon(Iconsax.moon),
        onSelected: () => changeTheme(ThemeMode.dark),
      ),
      ContextMenuItem(
        title: ThemeMode.light.name.tr,
        leading: const Icon(Iconsax.sun_1),
        onSelected: () => changeTheme(ThemeMode.light),
      ),
    ];
  }

  // PROPERTIES
  final busyMessage = ''.obs;
  final theme = Persistence.to.theme.val.obs;

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
  void changeTheme(ThemeMode mode) async {
    if (mode.name == Persistence.to.theme.val) return;
    Persistence.to.theme.val = mode.name;
    theme.value = mode.name;
    if (GetPlatform.isDesktop) Get.back();
    Get.changeThemeMode(mode);
    // reload main listview to fix refresh the backgrounds of tags
    MainScreenController.to.data.clear();
    await Future.delayed(200.milliseconds);
    MainScreenController.to.load();
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

    final exportFileName =
        '${WalletService.to.longAddress}.wallet.$kWalletExtension';

    final tempFile = File(join(
      LisoPaths.temp!.path,
      exportFileName,
    ));

    await tempFile.writeAsString(Persistence.to.wallet.val);

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [tempFile.path],
        subject: exportFileName,
        text: GetPlatform.isIOS ? null : 'Liso Wallet',
      );
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
    FileUtils.move(tempFile, join(exportPath, exportFileName));
    change('Exporting to: $exportPath', status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Exported Wallet File',
      body: exportFileName,
    );
  }

  void exportVault({bool encrypt = true}) {
    void _export() async {
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
          '${WalletService.to.longAddress}-${dateFormat.format(DateTime.now())}.${encrypt ? kVaultExtension : 'json'}';

      final vaultFile = await HiveItemsService.to.export(
        path: join(LisoPaths.tempPath, exportFileName),
        encrypt: encrypt,
      );

      console.info('vault file path: ${vaultFile.path}');

      if (GetPlatform.isMobile) {
        await Share.shareFiles(
          [vaultFile.path],
          subject: exportFileName,
          text: GetPlatform.isIOS ? null : '${ConfigService.to.appName} Vault',
        );

        console.info('done');
        Get.back();
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
      change(null, status: RxStatus.success());

      NotificationsManager.notify(
        title: 'Exported Vault',
        body: exportFileName,
      );

      Get.back();
    }

    UIUtils.showImageDialog(
      Icon(Iconsax.box_1, size: 100, color: themeColor),
      title: 'Export Vault',
      subTitle:
          "You'll be prompted to save a <vault>.$kVaultExtension file. Please store it offline or in a secure digital cloud storage",
      body:
          "Remember, your master mnemonic seed phrase that you backed up is the only key to decrypt your vault file",
      closeText: 'Cancel',
      action: _export,
      actionText: 'Export',
    );
  }

  void showSeed() async {
    // prompt password from unlock screen
    final unlocked = await Get.toNamed(
          Routes.unlock,
          parameters: {'mode': 'password_prompt'},
        ) ??
        false;

    if (!unlocked) return;

    Utils.adaptiveRouteOpen(
      name: Routes.seed,
      parameters: {'mode': 'display'},
    );
  }

  void purge() async {
    void _reset() async {
      // prompt password from unlock screen
      final unlocked = await Get.toNamed(
            Routes.unlock,
            parameters: {'mode': 'password_prompt'},
          ) ??
          false;

      if (!unlocked) return;
      // clear database
      await HiveItemsService.to.purge();
      await HiveGroupsService.to.purge();
      // reload lists
      MainScreenController.to.load();

      NotificationsManager.notify(
        title: 'Vault Purged',
        body: 'Your vault has been purged',
      );

      Get.back();
    }

    UIUtils.showImageDialog(
      const Icon(Iconsax.warning_2, size: 100, color: Colors.orange),
      title: 'Purge Vault?',
      subTitle: 'All items and custom vaults will be deleted',
      body: 'Please proceed with caution',
      closeText: 'Cancel',
      action: _reset,
      actionText: 'Purge',
    );
  }

  void reset() {
    void _reset() async {
      // prompt password from unlock screen
      final unlocked = await Get.toNamed(
            Routes.unlock,
            parameters: {'mode': 'password_prompt'},
          ) ??
          false;

      if (!unlocked) return;

      await LisoManager.reset();

      NotificationsManager.notify(
        title: 'Vault Reset',
        body: 'Your local vault has been successfully reset',
      );

      Get.offNamedUntil(Routes.main, (route) => false);
    }

    UIUtils.showImageDialog(
      const Icon(Iconsax.warning_2, size: 100, color: Colors.red),
      title: 'Reset ${ConfigService.to.appName}?',
      subTitle:
          'Your local <vault>.$kVaultExtension will be deleted and you will be logged out.',
      body:
          'Make sure you have a backup of your vault file and master mnemonic seed phrase before you proceed',
      closeText: 'Cancel',
      action: _reset,
      actionText: 'Reset',
    );
  }
}
