import 'dart:convert';
import 'dart:io';

import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/purchases/purchases.services.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/categories/categories.service.dart';
import 'package:liso/features/files/sync.service.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/liso/liso.manager.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/services/cipher.service.dart';
import '../app/routes.dart';
import '../groups/groups.service.dart';
import '../menu/menu.item.dart';

class SettingsScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static SettingsScreenController get to => Get.find();

  // VARIABLES

  List<ContextMenuItem> get menuItemsTheme {
    return [
      ContextMenuItem(
        title: ThemeMode.system.name.tr,
        leading: const Icon(Iconsax.cpu_outline),
        onSelected: () => changeTheme(ThemeMode.system),
      ),
      ContextMenuItem(
        title: ThemeMode.dark.name.tr,
        leading: const Icon(Iconsax.moon_outline),
        onSelected: () => changeTheme(ThemeMode.dark),
      ),
      ContextMenuItem(
        title: ThemeMode.light.name.tr,
        leading: const Icon(Iconsax.sun_1_outline),
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
  void onInit() async {
    change(GetStatus.success(null));
    super.onInit();
  }

  @override
  void onReady() {
    if (gParameters['expand'] == 'account') {
      updateLicenseKey();
    }

    super.onReady();
  }

  @override
  void change(status) {
    busyMessage.value = status.isLoading ? 'Exporting...' : '';
    super.change(status);
  }

  // FUNCTIONS
  void changeTheme(ThemeMode mode) async {
    if (mode.name == Persistence.to.theme.val) return;
    Persistence.to.theme.val = mode.name;
    theme.value = mode.name;
    Get.changeThemeMode(mode);
    // reload items listview to refresh the backgrounds of tags
    ItemsController.to.data.clear();
    await Future.delayed(200.milliseconds);
    ItemsController.to.load();

    if (isDesktop) {
      MainScreenController.to.window.setBrightness(
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
    }

    if (!isSmallScreen) Get.backLegacy();
  }

  void exportWallet() async {
    // prompt password from unlock screen
    final unlocked = await Get.toNamed(
          Routes.unlock,
          parameters: {
            'mode': 'poppable',
            'reason': 'Export Wallet File',
          },
        ) ??
        false;

    if (!unlocked) return console.error('unlock failed');
    if (status == GetStatus.loading()) return console.error('still busy');
    change(GetStatus.loading());

    final exportFileName =
        '${SecretPersistence.to.walletAddress.val}.wallet.$kWalletExtension';

    final tempFile = File(join(
      LisoPaths.temp!.path,
      exportFileName,
    ));

    await tempFile.writeAsString(SecretPersistence.to.wallet.val);

    if (GetPlatform.isMobile) {
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: exportFileName,
        text: GetPlatform.isIOS ? null : 'Liso Wallet',
      );

      NotificationsService.to.notify(
        title: 'Exported Wallet File',
        body: exportFileName,
      );

      return change(GetStatus.success(null));
    }

    change(GetStatus.loading());
    timeLockEnabled = false; // temporarily disable
    // choose directory and export file
    final exportPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Export Path',
    );

    timeLockEnabled = true; // re-enable
    // user cancelled picker
    if (exportPath == null) {
      console.warning('user cancelled picker');
      return change(GetStatus.success(null));
    }

    console.info('export path: $exportPath');
    change(GetStatus.loading());
    await Future.delayed(1.seconds); // just for style
    FileUtils.move(tempFile, join(exportPath, exportFileName));
    change(GetStatus.success(null));

    NotificationsService.to.notify(
      title: 'Exported Wallet File',
      body: exportFileName,
    );
  }

  void exportVault({bool encrypt = true}) {
    void export() async {
      // prompt password from unlock screen
      final unlocked = await Get.toNamed(
            Routes.unlock,
            parameters: {
              'mode': 'poppable',
              'reason': 'Export Vault File',
            },
          ) ??
          false;

      if (!unlocked) return;
      if (status == GetStatus.loading()) return console.error('still busy');
      change(GetStatus.loading());

      // File Name
      final dateFormat = DateFormat('MMM-dd-yyyy_hh-mm_aaa');
      final exportFileName =
          '${SecretPersistence.to.longAddress}-${dateFormat.format(DateTime.now())}.${encrypt ? kVaultExtension : 'json'}';

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
        await Share.shareXFiles(
          [XFile(vaultFile.path)],
          subject: exportFileName,
          text: GetPlatform.isIOS ? null : '${config.name} Vault',
        );

        NotificationsService.to.notify(
          title: 'Exported Vault',
          body: exportFileName,
        );

        Get.backLegacy(); // close dialog
        return change(GetStatus.success(null));
      }

      change(GetStatus.loading());
      timeLockEnabled = false; // temporarily disable
      // choose directory and export file
      final exportPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose Export Path',
      );

      timeLockEnabled = true; // re-enable
      // user cancelled picker
      if (exportPath == null) {
        return change(GetStatus.success(null));
      }

      console.info('export path: $exportPath');
      change(GetStatus.loading());
      await Future.delayed(1.seconds); // just for style
      await FileUtils.move(vaultFile, join(exportPath, exportFileName));
      change(GetStatus.success(null));

      NotificationsService.to.notify(
        title: 'Exported Vault',
        body: exportFileName,
      );

      Get.backLegacy();
    }

    UIUtils.showImageDialog(
      Icon(Iconsax.box_1_outline, size: 100, color: themeColor),
      title: 'Export Vault',
      subTitle: encrypt
          ? "You'll be prompted to save an encrypted <vault>.$kVaultExtension file. Please store it offline or in a secure digital cloud storage"
          : "You'll be prompted to save an unencrypted <vault>.json file.",
      body: encrypt
          ? "Remember, your master mnemonic seed phrase that you backed up is the only key to decrypt your vault file"
          : "Please keep in mind this is an unencrypted vault file and leaking it will be exposed to hackers.",
      closeText: 'Cancel',
      action: export,
      actionText: 'Export',
    );
  }

  void showSeed() async {
    // prompt password from unlock screen
    final unlocked = await Get.toNamed(
          Routes.unlock,
          parameters: {
            'mode': 'poppable',
            'reason': 'Show Master Seed Phrase',
          },
        ) ??
        false;

    if (!unlocked) return;

    Utils.adaptiveRouteOpen(
      name: AppRoutes.seed,
      parameters: {'mode': 'display'},
    );
  }

  void purge() async {
    void reset() async {
      // prompt password from unlock screen
      final unlocked = await Get.toNamed(
            Routes.unlock,
            parameters: {
              'mode': 'poppable',
              'reason': 'Purge Items',
            },
          ) ??
          false;

      if (!unlocked) return;
      // clear database
      await ItemsService.to.box?.clear();
      await GroupsService.to.box?.clear();
      await CategoriesService.to.box?.clear();
      // reload lists
      MainScreenController.to.load();

      NotificationsService.to.notify(
        title: 'Vault Purged',
        body: 'Your vault has been purged',
      );

      Get.backLegacy();
    }

    UIUtils.showImageDialog(
      const Icon(Iconsax.warning_2_outline, size: 100, color: Colors.orange),
      title: 'Purge Vault?',
      subTitle:
          'All items, custom vaults, and custom categories will be deleted',
      body:
          'Please proceed with caution.${PurchasesService.to.isPremium ? '\n\nYour purchases will not be removed' : ''}',
      closeText: 'Cancel',
      action: reset,
      actionText: 'Purge',
      actionStyle: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
      ),
    );
  }

  void unsync() async {
    void confirm() async {
      // prompt password from unlock screen
      final unlocked = await Get.toNamed(
            Routes.unlock,
            parameters: {
              'mode': 'poppable',
              'reason': 'Delete Remote Data',
            },
          ) ??
          false;

      if (!unlocked) return;

      final result = await SyncService.to.purge();

      if (result.isLeft) {
        return UIUtils.showSimpleDialog(
          'Error Deleting',
          'An error occured while trying to delete your remote vault. Please try again later.',
        );
      }

      NotificationsService.to.notify(
        title: 'Remote Vault Deleted',
        body: 'Your remote vault has been deleted',
      );

      Get.backLegacy();
    }

    UIUtils.showImageDialog(
      const Icon(Iconsax.warning_2_outline, size: 100, color: Colors.red),
      title: 'Warning',
      subTitle:
          'By proceeding you will only delete your remote <vault>.$kVaultExtension, backups, files, and shared vaults.',
      body:
          'This cannot be undone. Your local and offline vault will still remain.${PurchasesService.to.isPremium ? '\n\nYour purchases will not be removed' : ''}',
      closeText: 'Cancel',
      action: confirm,
      actionText: 'Proceed',
      actionStyle: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void reset() {
    void confirm() async {
      // prompt password from unlock screen
      final unlocked = await Get.toNamed(
            Routes.unlock,
            parameters: {
              'mode': 'poppable',
              'reason': 'Reset your vault',
            },
          ) ??
          false;

      if (!unlocked) return;
      await LisoManager.reset();

      NotificationsService.to.notify(
        title: 'Vault Reset',
        body: 'Your local vault has been successfully reset',
      );
    }

    UIUtils.showImageDialog(
      const Icon(Iconsax.warning_2_outline, size: 100, color: Colors.red),
      title: 'Reset ${config.name}?',
      subTitle:
          'Your local <vault>.$kVaultExtension will be deleted and you will be logged out.',
      body:
          'Make sure you have a backup of your vault file and master mnemonic seed phrase before you proceed.${PurchasesService.to.isPremium ? '\n\nYour purchases will not be removed' : ''}',
      closeText: 'Cancel',
      action: confirm,
      actionText: 'Reset',
      actionStyle: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void showDiagnosticInfo() async {
    final content = ListView(
      shrinkWrap: true,
      controller: ScrollController(),
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          title: const Text('User ID'),
          subtitle: Text(AuthService.to.user?.id ?? ''),
          dense: true,
          onTap: () => Utils.copyToClipboard(
            AuthService.to.user!.id,
          ),
        ),
        ListTile(
          title: const Text('RC User ID'),
          subtitle: Text(PurchasesService.to.info.value.originalAppUserId),
          dense: true,
          onTap: () => Utils.copyToClipboard(
            PurchasesService.to.info.value.originalAppUserId,
          ),
        ),
        // ListTile(
        //   title: Text('${config.name} Pro'),
        //   subtitle: Text(PurchasesService.to.isPremium.toString()),
        //   dense: true,
        // ),
        // ListTile(
        //   title: const Text('Free Trial'),
        //   subtitle: Text(PurchasesService.to.isFreeTrial.toString()),
        // ),
        ListTile(
          title: const Text('App Version'),
          subtitle: Text(metadataApp.formattedVersion),
          dense: true,
        ),
        ListTile(
          title: const Text('Platform'),
          subtitle: Text(Utils.platform),
          dense: true,
        ),
      ],
    );

    final dialog = AlertDialog(
      title: const Text('Diagnostics Info'),
      content: Container(
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
    );

    try {
      Get.dialog(dialog);
    } catch (e) {
      console.error(e.toString());
    }

    AnalyticsService.to.logEvent('show-diagnostics');
  }

  void updateLicenseKey() {
    if (AuthService.to.authenticated) {
      UIUtils.setLicenseKey();
    } else {
      UIUtils.showSimpleDialog(
        'Sign In Required',
        'Please sign up or sign in to update your license key',
      );
    }
  }
}
