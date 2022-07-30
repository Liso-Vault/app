import 'dart:convert';
import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/categories/categories.service.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/liso/liso.manager.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/services/cipher.service.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../groups/groups.service.dart';
import '../menu/menu.item.dart';
import '../pro/pro.controller.dart';
import '../wallet/wallet.service.dart';

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
    // reload items listview to refresh the backgrounds of tags
    ItemsController.to.data.clear();
    await Future.delayed(200.milliseconds);
    ItemsController.to.load();
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

      // File Name
      final dateFormat = DateFormat('MMM-dd-yyyy_hh-mm_aaa');
      final exportFileName =
          '${WalletService.to.longAddress}-${dateFormat.format(DateTime.now())}.${encrypt ? kVaultExtension : 'json'}';

      // Vault Compaction
      String vaultString = await LisoManager.compactJson();
      List<int> vaultBytes = utf8.encode(vaultString);

      // Vault Encryption
      if (encrypt) {
        vaultBytes = CipherService.to.encrypt(
          utf8.encode(vaultString),
        );
      }

      // Vault File
      final vaultFile = await File(join(
        LisoPaths.tempPath,
        exportFileName,
      )).writeAsBytes(vaultBytes);

      console.info('vault file path: ${vaultFile.path}');

      // Share for Mobile
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
      subTitle: encrypt
          ? "You'll be prompted to save an encrypted <vault>.$kVaultExtension file. Please store it offline or in a secure digital cloud storage"
          : "You'll be prompted to save an unencrypted <vault>.json file.",
      body: encrypt
          ? "Remember, your master mnemonic seed phrase that you backed up is the only key to decrypt your vault file"
          : "Please keep in mind this is an unencrypted vault file and leaking it will be exposed to hackers.",
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
      await ItemsService.to.box?.clear();
      await GroupsService.to.box?.clear();
      await CategoriesService.to.box?.clear();
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
      subTitle:
          'All items, custom vaults, and custom categories will be deleted',
      body:
          'Please proceed with caution.${ProController.to.isPro ? '\n\nYour purchases will not be removed' : ''}',
      closeText: 'Cancel',
      action: _reset,
      actionText: 'Purge',
      actionStyle: ElevatedButton.styleFrom(
        primary: Colors.orange,
      ),
    );
  }

  void unsync() async {
    void _unsync() async {
      // prompt password from unlock screen
      final unlocked = await Get.toNamed(
            Routes.unlock,
            parameters: {'mode': 'password_prompt'},
          ) ??
          false;

      if (!unlocked) return;

      final result = await S3Service.to.purge();

      if (result.isLeft) {
        return UIUtils.showSimpleDialog(
          'Error Deleting',
          'An error occured while trying to delete your remote vault. Please try again later.',
        );
      }

      NotificationsManager.notify(
        title: 'Remote Vault Deleted',
        body: 'Your remote vault has been deleted',
      );

      Get.back();
    }

    UIUtils.showImageDialog(
      const Icon(Iconsax.warning_2, size: 100, color: Colors.red),
      title: 'Warning',
      subTitle:
          'By proceeding you will only delete your remote <vault>.$kVaultExtension, backups, files, and shared vaults.',
      body:
          'This cannot be undone. Your local and offline vault will still remain.${ProController.to.isPro ? '\n\nYour purchases will not be removed' : ''}',
      closeText: 'Cancel',
      action: _unsync,
      actionText: 'Proceed',
      actionStyle: ElevatedButton.styleFrom(
        primary: Colors.redAccent,
      ),
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
          'Make sure you have a backup of your vault file and master mnemonic seed phrase before you proceed.${ProController.to.isPro ? '\n\nYour purchases will not be removed' : ''}',
      closeText: 'Cancel',
      action: _reset,
      actionText: 'Reset',
      actionStyle: ElevatedButton.styleFrom(
        primary: Colors.redAccent,
      ),
    );
  }

  void showDiagnosticInfo() async {
    final content = ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: const Text('Wallet Address'),
          subtitle: Text(WalletService.to.longAddress),
          onTap: () => Utils.copyToClipboard(
            WalletService.to.longAddress,
          ),
        ),
        ListTile(
          title: const Text('User ID'),
          subtitle: Text(AuthService.to.userId),
          onTap: () => Utils.copyToClipboard(
            AuthService.to.userId,
          ),
        ),
        ListTile(
          title: const Text('RC User ID'),
          subtitle: Text(ProController.to.info.value.originalAppUserId),
          onTap: () => Utils.copyToClipboard(
            ProController.to.info.value.originalAppUserId,
          ),
        ),
        ListTile(
          title: const Text('Pro User'),
          subtitle: Text(ProController.to.isPro.toString()),
        ),
        ListTile(
          title: const Text('Free Trial'),
          subtitle: Text(ProController.to.isFreeTrial.toString()),
        ),
        ListTile(
          title: const Text('Entitlement'),
          subtitle: Text(ProController.to.limits.id),
        ),
        ListTile(
          title: const Text('App Version'),
          subtitle: Text(Globals.metadata?.app.formattedVersion ?? ''),
        ),
        ListTile(
          title: const Text('Platform'),
          subtitle: Text(Utils.platformName()),
        ),
      ],
    );

    await Get.dialog(
      AlertDialog(
        title: const Text('Diagnostics Info'),
        content: Utils.isDrawerExpandable
            ? content
            : Container(
                constraints: const BoxConstraints(maxHeight: 600),
                width: 400,
                child: content,
              ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('okay'.tr),
          ),
          // TextButton(
          //   onPressed: () => Utils.copyToClipboard(text),
          //   child: Text('copy'.tr),
          // ),
        ],
      ),
    );
  }
}
