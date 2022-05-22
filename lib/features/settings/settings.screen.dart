import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/hive/hive.manager.dart';
import '../../core/persistence/persistence_builder.widget.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import 'settings_screen.controller.dart';

class SettingsScreen extends GetView<SettingsScreenController>
    with ConsoleMixin {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final persistence = Get.find<Persistence>();
    final config = Get.find<ConfigService>();

    final listView = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const SizedBox(height: 20),
        Obx(
          () => ContextMenuButton(
            controller.menuItemsTheme,
            useMouseRegion: true,
            padding: EdgeInsets.zero,
            initialItem: controller.menuItemsTheme.firstWhere(
              (e) => e.title.toLowerCase() == controller.theme.value,
            ),
            child: ListTile(
              leading: Icon(Iconsax.color_swatch, color: themeColor),
              trailing: const Icon(Iconsax.arrow_right_3),
              title: Text('theme'.tr),
              subtitle: Obx(() => Text(controller.theme().tr)),
            ),
          ),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.setting_3, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('configuration'.tr),
          subtitle: const Text('Cloud Sync & Anonymous Reporting'),
          onTap: () => Utils.adaptiveRouteOpen(
            name: Routes.configuration,
            parameters: {'from': 'settings'},
          ),
        ),
        const Divider(),
        PersistenceBuilder(
          builder: (p, context) => SwitchListTile(
              title: const Text('File Encryption'),
              secondary: Icon(
                Iconsax.shield_tick,
                color: themeColor,
              ),
              value: persistence.fileEncryption.val,
              subtitle: const Text(
                  "Automatic client-side file encryption when you upload files"),
              onChanged: (value) {
                if (WalletService.to.limits.fileEncryption) {
                  persistence.fileEncryption.val = value;
                  return;
                }

                Utils.adaptiveRouteOpen(
                  name: Routes.upgrade,
                  parameters: {
                    'title': 'Title',
                    'body': 'Upgrade to enable file encryption',
                  }, // TODO: add message
                );
              }),
        ),
        const Divider(),
        ListTile(
          title: Text('time_machine'.tr),
          subtitle: const Text('Go back in time to undo your changes'),
          leading: Icon(Iconsax.clock, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () {
            if (!persistence.sync.val) {
              return UIUtils.showSimpleDialog(
                'Sync Required',
                'Please turn on ${config.appName} Cloud Sync to use this feature',
              );
            }

            Utils.adaptiveRouteOpen(
              name: Routes.s3Explorer,
              parameters: {'type': 'time_machine'},
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.import_1, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: const Text('Import Items'),
          subtitle: const Text('Import items from external sources'),
          // enabled: false,
          onTap: () {
            UIUtils.showSimpleDialog(
              'Import Items',
              "Soon, you'll be able to import items from 1Password, LastPass, etc...",
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.box_1, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('export_vault'.tr),
          subtitle: const Text('Save <vault>.liso to an external source'),
          onTap: () {
            if (HiveManager.items == null || HiveManager.items!.isEmpty) {
              return UIUtils.showSimpleDialog(
                'Empty Vault',
                'Cannot export an empty vault.',
              );
            }

            Utils.adaptiveRouteOpen(name: Routes.export);
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.wallet_1, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('export_wallet'.tr),
          subtitle: const Text('Save <wallet>.json to an external source'),
          onTap: controller.exportWallet,
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.key, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: const Text('Show Seed Phrase'),
          subtitle: const Text('Make sure you are in a safe location'),
          onTap: controller.showSeed,
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.lock, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${'lock'.tr} ${config.appName}'),
          subtitle: const Text('Exit and lock the app'),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.refresh5, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${'reset'.tr} ${config.appName}'),
          subtitle: const Text('Delete local vault and start over'),
          onTap: () => Utils.adaptiveRouteOpen(name: Routes.reset),
        ),
        const Divider(),
        if (kDebugMode) ...[
          ListTile(
            leading: const Icon(Iconsax.code),
            trailing: const Icon(Iconsax.arrow_right_3),
            title: const Text('Debugging'),
            onTap: () => Utils.adaptiveRouteOpen(name: Routes.debug),
            selected: true,
            selectedColor: Colors.red,
          ),
          const Divider(),
        ]
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        centerTitle: false,
        leading: const AppBarLeadingButton(),
      ),
      body: controller.obx(
        (_) => listView,
        onLoading: Obx(
          () => BusyIndicator(
            message: controller.busyMessage.value,
          ),
        ),
      ),
    );
  }
}
