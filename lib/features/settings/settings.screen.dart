import 'package:app_core/config/app.model.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/license/license.service.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence_builder.widget.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/autofill/autofill.service.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../menu/menu.item.dart';
import 'settings_screen.controller.dart';

class SettingsScreen extends StatelessWidget with ConsoleMixin {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsScreenController());

    final listView = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const SizedBox(height: 20),
        PersistenceBuilder(builder: (p, context) {
          return ExpansionTile(
            title: const Text('App Theme'),
            subtitle: Text(controller.theme().tr),
            leading: Icon(Iconsax.color_swatch, color: themeColor),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              ListTile(
                leading: Icon(Iconsax.cpu, color: themeColor),
                selected: p.theme.val == ThemeMode.system.name,
                title: Text(ThemeMode.system.name.tr),
                trailing: p.theme.val == ThemeMode.system.name
                    ? Icon(Icons.check, color: themeColor)
                    : null,
                onTap: () => controller.changeTheme(ThemeMode.system),
              ),
              ListTile(
                leading: Icon(Iconsax.moon, color: themeColor),
                selected: p.theme.val == ThemeMode.dark.name,
                title: Text(ThemeMode.dark.name.tr),
                trailing: p.theme.val == ThemeMode.dark.name
                    ? Icon(Icons.check, color: themeColor)
                    : null,
                onTap: () => controller.changeTheme(ThemeMode.dark),
              ),
              ListTile(
                leading: Icon(Iconsax.sun_1, color: themeColor),
                selected: p.theme.val == ThemeMode.light.name,
                title: Text(ThemeMode.light.name.tr),
                trailing: p.theme.val == ThemeMode.light.name
                    ? Icon(Icons.check, color: themeColor)
                    : null,
                onTap: () => controller.changeTheme(ThemeMode.light),
              ),
            ],
          );
        }),
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
                value: AppPersistence.to.sync.val,
                subtitle: const Text("Keep multiple devices in sync"),
                onChanged: (value) => AppPersistence.to.sync.val = value,
              ),
              // TODO: temporary
              // if (p.sync.val) ...[
              // if (!GetPlatform.isWindows) ...[
              //   ListTile(
              //     leading: Icon(Iconsax.cpu, color: themeColor),
              //
              //     title: const Text('Devices'),
              //     subtitle: const Text('Manage your synced devices'),
              //     onTap: () => Utils.adaptiveRouteOpen(name: Routes.devices),
              //   ),
              // ],
              // ListTile(
              //   leading: Icon(Iconsax.setting, color: themeColor),
              //
              //   title: const Text('Configuration'),
              //   subtitle: const Text('Change your sync configuration'),
              //   onTap: () => Utils.adaptiveRouteOpen(
              //     name: Routes.syncProvider,
              //   ),
              // ),
              // ],
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
                title: const Text('Custom Categories'),
                subtitle: const Text('Manage your custom categories'),
                onTap: () =>
                    Utils.adaptiveRouteOpen(name: AppRoutes.categories),
              ),
              ListTile(
                leading: Icon(Iconsax.briefcase, color: themeColor),
                title: const Text('Custom Vaults'),
                subtitle: const Text('Manage your custom vaults'),
                onTap: () => Utils.adaptiveRouteOpen(name: AppRoutes.vaults),
              ),
              if (AppPersistence.to.canShare) ...[
                // TODO: temporary
                // ListTile(
                //   leading: Icon(Iconsax.share, color: themeColor),
                //
                //   title: const Text('Shared Vaults'),
                //   subtitle: const Text('Manage your shared vaults'),
                //   onTap: () => Utils.adaptiveRouteOpen(
                //     name: Routes.sharedVaults,
                //   ),
                // ),
                // ListTile(
                //   leading: Icon(LineIcons.plus, color: themeColor),
                //
                //   title: const Text('Joined Vaults'),
                //   subtitle: const Text('Manage your joined vaults'),
                //   onTap: () => Utils.adaptiveRouteOpen(
                //     name: Routes.joinedVaults,
                //   ),
                // ),
                ListTile(
                  title: const Text('Backed Up Vaults'),
                  subtitle: const Text('Go back in time to undo your changes'),
                  leading: Icon(Iconsax.box, color: themeColor),
                  onTap: () async {
                    if (!AppPersistence.to.sync.val) {
                      return UIUtils.showSimpleDialog(
                        'Sync Required',
                        'Please turn on ${appConfig.name} Cloud Sync to use this feature',
                      );
                    }

                    Utils.adaptiveRouteOpen(
                      name: AppRoutes.s3Explorer,
                      parameters: {'type': 'time_machine'},
                    );
                  },
                ),
              ],
              ListTile(
                leading: Icon(Iconsax.import_1, color: themeColor),
                title: const Text('Import Items'),
                subtitle: const Text('Import items from external sources'),
                onTap: () => Utils.adaptiveRouteOpen(name: AppRoutes.import),
              ),
              ContextMenuButton(
                padding: EdgeInsets.zero,
                [
                  ContextMenuItem(
                    title: 'Encrypted',
                    onSelected: () => controller.exportVault(),
                    leading: Icon(Iconsax.shield_tick, size: popupIconSize),
                  ),
                  ContextMenuItem(
                    title: 'Unencrypted',
                    onSelected: () => controller.exportVault(encrypt: false),
                    leading: Icon(Iconsax.document, size: popupIconSize),
                  )
                ],
                child: ListTile(
                  leading: Icon(Iconsax.box_1, color: themeColor),
                  title: Text('export_vault'.tr),
                  subtitle:
                      const Text('Save <vault>.liso to an external source'),
                  onTap: controller.exportVault,
                ),
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
                leading: Icon(Iconsax.key, color: themeColor),
                title: const Text('Show Seed Phrase'),
                subtitle: const Text('Make sure you are in a safe location'),
                onTap: controller.showSeed,
              ),
              // ListTile(
              //   leading: Icon(Iconsax.password_check, color: themeColor),
              //
              //   title: const Text('Change Password'),
              //   subtitle: const Text('Change your wallet password'),
              //   // onTap: controller.showSeed,
              // ),
              ListTile(
                leading: Icon(Iconsax.wallet_1, color: themeColor),
                title: Text('export_wallet'.tr),
                subtitle: const Text(
                  'Save <wallet>.json to an external source',
                ),
                onTap: controller.exportWallet,
              ),
            ],
          );
        }),
        Obx(
          () => Visibility(
            visible: LisoAutofillService.to.supported.value,
            child: ExpansionTile(
              title: const Text('Autofill Settings'),
              subtitle: Text(
                '${appConfig.name} autofill service settings',
              ),
              leading: Icon(Iconsax.rulerpen, color: themeColor),
              childrenPadding: const EdgeInsets.only(left: 20),
              children: [
                ListTile(
                  leading: Icon(Iconsax.setting_2, color: themeColor),
                  title: Text('${appConfig.name} Autofill Service'),
                  onTap: LisoAutofillService.to.set,
                  subtitle: Obx(
                    () => Text(
                      LisoAutofillService.to.enabled.value
                          ? 'Enabled'
                          : 'Set ${appConfig.name} as your autofill service',
                    ),
                  ),
                ),
                Visibility(
                  visible: LisoAutofillService.to.enabled.value,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: SwitchListTile(
                      title: const Text('Auto Save'),
                      subtitle: Text(
                        'Automatically save passwords to ${appConfig.name}',
                      ),
                      secondary: Icon(Iconsax.setting_2, color: themeColor),
                      value: LisoAutofillService.to.saving.value,
                      onChanged: (value) =>
                          LisoAutofillService.to.toggleSaving(value),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        PersistenceBuilder(builder: (p, context) {
          return ExpansionTile(
            title: const Text('Other Settings'),
            subtitle: const Text('A few other settings'),
            leading: Icon(Iconsax.chart_2, color: themeColor),
            childrenPadding: const EdgeInsets.only(left: 20),
            initiallyExpanded: Get.parameters['expand'] == 'other_settings',
            children: [
              if (!isApple || kDebugMode) ...[
                ListTile(
                  leading: Icon(Icons.key, color: themeColor),
                  title: Text('license_key'.tr), // TODO: localize
                  subtitle: Obx(
                    () => Text(LicenseService.to.license.value.key),
                  ),
                  onTap: controller.updateLicenseKey,
                ),
              ],
              SwitchListTile(
                title: const Text('Errors & Crashes'),
                secondary: Icon(Iconsax.cpu, color: themeColor),
                value: p.crashReporting.val,
                subtitle: const Text("Send anonymous crash reports"),
                onChanged: (value) => p.crashReporting.val = value,
              ),
              SwitchListTile(
                title: const Text('Usage Statistics'),
                secondary: Icon(Iconsax.chart_square, color: themeColor),
                value: p.analytics.val,
                subtitle: const Text('Send anonymous usage statistics'),
                onChanged: (value) => p.analytics.val = value,
              ),
              ListTile(
                leading: Icon(LineIcons.infoCircle, color: themeColor),
                title: const Text('Show Diagnostics Info'),
                onTap: controller.showDiagnosticInfo,
              ),
            ],
          );
        }),
        ListTile(
          leading: Icon(Iconsax.lock, color: themeColor),
          title: Text('${'lock'.tr} ${appConfig.name}'),
          subtitle: const Text('Exit and lock the app'),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        ExpansionTile(
          title: const Text('Danger Zone'),
          subtitle: const Text('Delete, purge, or reset your data'),
          leading: Icon(Iconsax.warning_2, color: themeColor),
          childrenPadding: const EdgeInsets.only(left: 20),
          children: [
            ListTile(
              iconColor: Colors.amber,
              leading: const Icon(Iconsax.refresh),
              title: Text('${'purge'.tr} Items'),
              subtitle: const Text('Clear all items and start over'),
              onTap: controller.purge,
            ),
            ListTile(
              iconColor: const Color(0xFFFF7300),
              leading: const Icon(Iconsax.refresh5),
              title: Text('${'reset'.tr} ${appConfig.name}'),
              subtitle: const Text('Delete local vault and logout'),
              onTap: controller.reset,
              onLongPress: () => Utils.adaptiveRouteOpen(name: Routes.debug),
            ),
            if (AppPersistence.to.canShare) ...[
              ListTile(
                iconColor: Colors.red,
                leading: const Icon(Iconsax.warning_2),
                title: const Text('Delete Remote Data'),
                subtitle: const Text('Delete remote vault and files'),
                onTap: controller.unsync,
              ),
            ],
            if (kDebugMode) ...[
              ListTile(
                leading: const Icon(Iconsax.code),
                title: const Text('Debugging'),
                onTap: () => Utils.adaptiveRouteOpen(name: Routes.debug),
                selected: true,
                selectedColor: Colors.red,
              ),
            ]
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        centerTitle: false,
        leading: const AppBarLeadingButton(),
        actions: [
          TextButton(
            onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
            child: const Text('Need Help ?'),
          ),
        ],
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
