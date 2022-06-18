import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/persistence/persistence_builder.widget.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import '../menu/menu.item.dart';
import 'settings_screen.controller.dart';

class SettingsScreen extends StatelessWidget with ConsoleMixin {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsScreenController());
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
        PersistenceBuilder(builder: (p, context) {
          return ExpansionTile(
            title: const Text('Sync Settings'),
            subtitle: const Text('Vault synchronization settings'),
            leading: Icon(Iconsax.cloud_change, color: themeColor),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              SwitchListTile(
                title: const Text('Enabled'),
                secondary: Icon(Iconsax.cloud, color: themeColor),
                value: p.sync.val,
                subtitle: const Text("Keep multiple devices in sync"),
                onChanged: (value) => p.sync.val = value,
              ),
              if (p.sync.val) ...[
                ListTile(
                  leading: Icon(Iconsax.setting, color: themeColor),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  title: const Text('Configuration'),
                  subtitle: const Text('Manage your sync configuration'),
                  onTap: () => Utils.adaptiveRouteOpen(
                    name: Routes.syncProvider,
                  ),
                ),
                if (isFirebaseSupported) ...[
                  ListTile(
                    leading: Icon(Iconsax.cpu, color: themeColor),
                    trailing: const Icon(Iconsax.arrow_right_3),
                    title: const Text('Devices'),
                    subtitle: const Text('Manage your synced devices'),
                    onTap: () => Utils.adaptiveRouteOpen(name: Routes.devices),
                  ),
                ]
              ],
            ],
          );
        }),
        PersistenceBuilder(builder: (p, context) {
          return ExpansionTile(
            title: const Text('Vault Settings'),
            subtitle: const Text('Manage your vaults'),
            leading: Icon(Iconsax.briefcase, color: themeColor),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              ListTile(
                leading: Icon(Iconsax.category, color: themeColor),
                trailing: const Icon(Iconsax.arrow_right_3),
                title: const Text('Custom Categories'),
                subtitle: const Text('Manage your custom categories'),
                onTap: () => Utils.adaptiveRouteOpen(name: Routes.categories),
              ),
              ListTile(
                leading: Icon(Iconsax.briefcase, color: themeColor),
                trailing: const Icon(Iconsax.arrow_right_3),
                title: const Text('Custom Vaults'),
                subtitle: const Text('Manage your custom vaults'),
                onTap: () => Utils.adaptiveRouteOpen(name: Routes.vaults),
              ),
              if (Persistence.to.canShare && isFirebaseSupported) ...[
                ListTile(
                  leading: Icon(Iconsax.share, color: themeColor),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  title: const Text('Shared Vaults'),
                  subtitle: const Text('Manage your shared vaults'),
                  onTap: () =>
                      Utils.adaptiveRouteOpen(name: Routes.sharedVaults),
                ),
                ListTile(
                  leading: Icon(LineIcons.plus, color: themeColor),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  title: const Text('Joined Vaults'),
                  subtitle: const Text('Manage your joined vaults'),
                  onTap: () =>
                      Utils.adaptiveRouteOpen(name: Routes.joinedVaults),
                ),
              ],
              ListTile(
                title: const Text('Backed Up Vaults'),
                subtitle: const Text('Go back in time and undo your changes'),
                leading: Icon(Iconsax.clock, color: themeColor),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: () async {
                  if (!p.sync.val) {
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
              ContextMenuButton(
                padding: EdgeInsets.zero,
                [
                  ContextMenuItem(
                    title: 'Encrypted',
                    onSelected: () => controller.exportVault(),
                    leading: const Icon(Iconsax.shield_tick),
                  ),
                  ContextMenuItem(
                    title: 'Unencrypted',
                    onSelected: () => controller.exportVault(encrypt: false),
                    leading: const Icon(Iconsax.document),
                  )
                ],
                child: ListTile(
                  leading: Icon(Iconsax.box_1, color: themeColor),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  title: Text('export_vault'.tr),
                  subtitle:
                      const Text('Save <vault>.liso to an external source'),
                  onTap: controller.exportVault,
                ),
              ),
              ListTile(
                leading: Icon(Iconsax.refresh, color: themeColor),
                trailing: const Icon(Iconsax.arrow_right_3),
                title: Text('${'purge'.tr} Vault'),
                subtitle: const Text('Delete all items and start over'),
                onTap: controller.purge,
              ),
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
            ],
          );
        }),
        PersistenceBuilder(builder: (p, context) {
          return ExpansionTile(
            title: const Text('Wallet Settings'),
            subtitle: const Text('Manage your wallet'),
            leading: Icon(Iconsax.wallet, color: themeColor),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              ListTile(
                leading: Icon(Iconsax.wallet_1, color: themeColor),
                trailing: const Icon(Iconsax.arrow_right_3),
                title: Text('export_wallet'.tr),
                subtitle:
                    const Text('Save <wallet>.json to an external source'),
                onTap: controller.exportWallet,
              ),

              ListTile(
                leading: Icon(Iconsax.key, color: themeColor),
                trailing: const Icon(Iconsax.arrow_right_3),
                title: const Text('Show Seed Phrase'),
                subtitle: const Text('Make sure you are in a safe location'),
                onTap: controller.showSeed,
              ),
              // ListTile(
              //   leading: Icon(Iconsax.password_check, color: themeColor),
              //   trailing: const Icon(Iconsax.arrow_right_3),
              //   title: const Text('Change Password'),
              //   subtitle: const Text('Change your wallet password'),
              //   // onTap: controller.showSeed,
              // ),
            ],
          );
        }),
        PersistenceBuilder(builder: (p, context) {
          return ExpansionTile(
            title: const Text('Other Settings'),
            subtitle: const Text('Anonymous reporting settings'),
            leading: Icon(Iconsax.chart_2, color: themeColor),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              SwitchListTile(
                title: const Text('Errors & Crashes'),
                secondary: Icon(
                  Iconsax.cpu,
                  color: themeColor,
                ),
                value: p.crashReporting.val,
                subtitle: const Text("Send anonymous crash reports"),
                onChanged: (value) => p.crashReporting.val = value,
              ),
              SwitchListTile(
                title: const Text('Usage Statistics'),
                secondary: Icon(
                  Iconsax.chart_square,
                  color: themeColor,
                ),
                value: p.analytics.val,
                subtitle: const Text('Send anonymous usage statistics'),
                onChanged: (value) => p.analytics.val = value,
              ),
            ],
          );
        }),
        ListTile(
          leading: Icon(Iconsax.lock, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${'lock'.tr} ${config.appName}'),
          subtitle: const Text('Exit and lock the app'),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        ListTile(
          leading: Icon(Iconsax.refresh5, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${'reset'.tr} ${config.appName}'),
          subtitle: const Text('Delete local vault and logout'),
          onTap: controller.reset,
          onLongPress: () => Utils.adaptiveRouteOpen(name: Routes.debug),
        ),
        if (kDebugMode) ...[
          ListTile(
            leading: const Icon(Iconsax.code),
            trailing: const Icon(Iconsax.arrow_right_3),
            title: const Text('Debugging'),
            onTap: () => Utils.adaptiveRouteOpen(name: Routes.debug),
            selected: true,
            selectedColor: Colors.red,
          ),
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
