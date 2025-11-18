import 'package:app_core/firebase/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence_builder.widget.dart';
import 'package:app_core/purchases/purchases.services.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:dash_flags/dash_flags.dart';
// import 'package:launch_at_startup/src/launch_at_startup.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/persistence/persistence.secret.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/config/locales.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../menu/menu.item.dart';
import 'settings_screen.controller.dart';

class SettingsScreen extends StatelessWidget with ConsoleMixin {
  const SettingsScreen({super.key});

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
            title: Text('app_theme'.tr),
            subtitle: Text(controller.theme().tr),
            leading: const Icon(Iconsax.color_swatch_outline),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              ListTile(
                leading: const Icon(Iconsax.cpu_outline),
                selected: p.theme.val == ThemeMode.system.name,
                title: Text(ThemeMode.system.name.tr),
                trailing: p.theme.val == ThemeMode.system.name
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => controller.changeTheme(ThemeMode.system),
              ),
              ListTile(
                leading: const Icon(Iconsax.moon_outline),
                selected: p.theme.val == ThemeMode.dark.name,
                title: Text(ThemeMode.dark.name.tr),
                trailing: p.theme.val == ThemeMode.dark.name
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => controller.changeTheme(ThemeMode.dark),
              ),
              ListTile(
                leading: const Icon(Iconsax.sun_1_outline),
                selected: p.theme.val == ThemeMode.light.name,
                title: Text(ThemeMode.light.name.tr),
                trailing: p.theme.val == ThemeMode.light.name
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => controller.changeTheme(ThemeMode.light),
              ),
            ],
          );
        }),
        PersistenceBuilder(builder: (p, context) {
          return ExpansionTile(
            title: Text('sync_settings'.tr),
            subtitle: Text('vault_synchronization_settings'.tr),
            leading: const Icon(Iconsax.cloud_change_outline),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              SwitchListTile(
                title: Text('enabled'.tr),
                secondary: const Icon(Iconsax.cloud_outline),
                value: AppPersistence.to.sync.val,
                subtitle: Text("keep_multiple_devices_in_sync".tr),
                onChanged: (value) => AppPersistence.to.sync.val = value,
              ),
              // TODO: temporary
              // if (p.sync.val) ...[
              // if (!GetPlatform.isWindows) ...[
              //   ListTile(
              //     leading: Icon(Iconsax.cpu),
              //
              //     title: const Text('Devices'),
              //     subtitle: const Text('Manage your synced devices'),
              //     onTap: () => Utils.adaptiveRouteOpen(name: Routes.devices),
              //   ),
              // ],
              // ListTile(
              //   leading: Icon(Iconsax.setting),
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
            title: Text('vault_settings'.tr),
            subtitle: Text('manage_your_vaults'.tr),
            leading: const Icon(Iconsax.briefcase_outline),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              ListTile(
                leading: const Icon(Iconsax.category_outline),
                title: Text('custom_categories'.tr),
                subtitle: Text('manage_your_custom_categories'.tr),
                onTap: () =>
                    Utils.adaptiveRouteOpen(name: AppRoutes.categories),
              ),
              ListTile(
                leading: const Icon(Iconsax.briefcase_outline),
                title: Text('custom_vaults'.tr),
                subtitle: Text('manage_your_custom_vaults'.tr),
                onTap: () => Utils.adaptiveRouteOpen(name: AppRoutes.vaults),
              ),
              if (AppPersistence.to.canShare) ...[
                // TODO: temporary
                // ListTile(
                //   leading: Icon(Iconsax.share),
                //
                //   title: Text('shared_vaults'.tr),
                //   subtitle: const Text('Manage your shared vaults'),
                //   onTap: () => Utils.adaptiveRouteOpen(
                //     name: Routes.sharedVaults,
                //   ),
                // ),
                // ListTile(
                //   leading: Icon(LineAwesome.plus),
                //
                //   title: Text('joined_vaults'.tr),
                //   subtitle: const Text('Manage your joined vaults'),
                //   onTap: () => Utils.adaptiveRouteOpen(
                //     name: Routes.joinedVaults,
                //   ),
                // ),
                ListTile(
                  title: Text('backed_up_vaults'.tr),
                  subtitle: Text('go_back_in_time_to_undo_your_changes'.tr),
                  leading: const Icon(Iconsax.box_outline),
                  onTap: () async {
                    if (!AppPersistence.to.sync.val) {
                      return UIUtils.showSimpleDialog(
                        'Sync Required',
                        'Please turn on ${general.name} Cloud Sync to use this feature',
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
                leading: const Icon(Iconsax.import_1_outline),
                title: Text('import_items'.tr),
                subtitle: Text('import_items_from_external_sources'.tr),
                onTap: () => Utils.adaptiveRouteOpen(name: AppRoutes.import),
              ),
              ContextMenuButton(
                padding: EdgeInsets.zero,
                [
                  ContextMenuItem(
                    title: 'encrypted'.tr,
                    onSelected: () => controller.exportVault(),
                    leading:
                        Icon(Iconsax.shield_tick_outline, size: popupIconSize),
                  ),
                  ContextMenuItem(
                    title: 'unencrypted'.tr,
                    onSelected: () => controller.exportVault(encrypt: false),
                    leading:
                        Icon(Iconsax.document_outline, size: popupIconSize),
                  )
                ],
                child: ListTile(
                  leading: const Icon(Iconsax.box_1_outline),
                  title: Text('export_vault'.tr),
                  subtitle: Text('save_vault_to_external_source'.tr),
                  onTap: controller.exportVault,
                ),
              ),
            ],
          );
        }),
        PersistenceBuilder(builder: (p, context) {
          return ExpansionTile(
            title: Text('wallet_settings'.tr),
            subtitle: Text('manage_your_wallet'.tr),
            leading: const Icon(Iconsax.wallet_outline),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              ListTile(
                leading: const Icon(Iconsax.key_outline),
                title: Text('show_seed_phrase'.tr),
                subtitle: Text('make_sure_you_are_in_a_safe_location'.tr),
                onTap: controller.showSeed,
              ),
              // ListTile(
              //   leading: Icon(Iconsax.password_check),
              //
              //   title: const Text('Change Password'),
              //   subtitle: const Text('Change your wallet password'),
              //   // onTap: controller.showSeed,
              // ),
              ListTile(
                leading: const Icon(Iconsax.wallet_1_outline),
                title: Text('export_wallet'.tr),
                subtitle: Text('export_wallet_to_external_source'.tr),
                onTap: controller.exportWallet,
              ),
            ],
          );
        }),
        // Obx(
        //   () => Visibility(
        //     visible: LisoAutofillService.to.supported.value,
        //     child: ExpansionTile(
        //       title: const Text('Autofill Settings'),
        //       subtitle: Text(
        //         '${config.name} autofill service settings',
        //       ),
        //       leading: const Icon(Iconsax.rulerpen_outline),
        //       childrenPadding: const EdgeInsets.only(left: 20),
        //       children: [
        //         ListTile(
        //           leading: const Icon(Iconsax.setting_2_outline),
        //           title: Text('${config.name} Autofill Service'),
        //           onTap: LisoAutofillService.to.set,
        //           subtitle: Obx(
        //             () => Text(
        //               LisoAutofillService.to.enabled.value
        //                   ? 'Enabled'
        //                   : 'Set ${config.name} as your autofill service',
        //             ),
        //           ),
        //         ),
        //         Visibility(
        //           visible: LisoAutofillService.to.enabled.value,
        //           child: Padding(
        //             padding: const EdgeInsets.only(left: 15),
        //             child: SwitchListTile(
        //               title: const Text('Auto Save'),
        //               subtitle: Text(
        //                 'Automatically save passwords to ${config.name}',
        //               ),
        //               secondary: const Icon(Iconsax.setting_2_outline),
        //               value: LisoAutofillService.to.saving.value,
        //               onChanged: (value) =>
        //                   LisoAutofillService.to.toggleSaving(value),
        //               contentPadding: EdgeInsets.zero,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        PersistenceBuilder(builder: (p, context) {
          final languageCode = Get.locale?.languageCode ?? '';
          var localeForIcon = languageCode;
          final splitted = languageCode.split('-');

          if (splitted.length > 1) {
            localeForIcon = splitted.first;
          }

          final language = kLocales[languageCode]?['name'] ?? '';

          return ExpansionTile(
            title: Text('language'.tr),
            subtitle: Row(
              children: [
                Text(language),
                const SizedBox(width: 10),
                LanguageFlag(
                  height: 10,
                  language: Language.fromCode(localeForIcon),
                ),
              ],
            ),
            leading: const Icon(Iconsax.language_circle_outline),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: controller.languageItems,
          );
        }),
        PersistenceBuilder(builder: (p, context) {
          return ExpansionTile(
            title: Text('other_settings'.tr),
            subtitle: Text('a_few_other_settings'.tr),
            leading: const Icon(Iconsax.chart_2_outline),
            childrenPadding: const EdgeInsets.only(left: 20),
            initiallyExpanded: gParameters['expand'] == 'account',
            children: [
              if (!isApple || kDebugMode) ...[
                ListTile(
                  leading: const Icon(Icons.key),
                  title: Text('license_key'.tr),
                  subtitle: Obx(
                    () => Text(PurchasesService.to.license.value.key),
                  ),
                  onTap: controller.updateLicenseKey,
                ),
              ],
              if (isDesktop) ...[
                // SwitchListTile(
                //   title: Text('launch_startup'.tr),
                //   secondary: const Icon(Iconsax.keyboard_open_outline),
                //   value: p.launchAtStartup.val,
                //   subtitle: const Text("Automatically launch on startup"),
                //   onChanged: (value) {
                //     p.launchAtStartup.val = value;

                //     if (value) {
                //       launchAtStartup.enable();
                //     } else {
                //       launchAtStartup.disable();
                //     }
                //   },
                // ),
                SwitchListTile(
                  title: Text('Minimize to ${isMac ? 'dock' : 'tray'}'),
                  secondary: const Icon(Iconsax.align_bottom_outline),
                  value: p.minimizeToTray.val,
                  subtitle: const Text("Minimize instead of terminating app"),
                  onChanged: (value) => p.minimizeToTray.val = value,
                ),
              ],
              SwitchListTile(
                title: Text('errors_crashes'.tr),
                secondary: const Icon(Iconsax.warning_2_outline),
                value: p.crashReporting.val,
                subtitle: Text('send_reports'.tr),
                onChanged: (value) => p.crashReporting.val = value,
              ),
              SwitchListTile(
                title: Text('usage_stats'.tr),
                secondary: const Icon(Iconsax.chart_square_outline),
                value: p.analytics.val,
                subtitle: Text('send_stats'.tr),
                onChanged: (value) => p.analytics.val = value,
              ),
              ListTile(
                leading: const Icon(Iconsax.info_circle_outline),
                trailing: const Icon(Iconsax.arrow_right_3_outline),
                title: Text('show_diagnostics_info'.tr),
                onTap: controller.showDiagnosticInfo,
              ),
            ],
          );
        }),
        ListTile(
          leading: const Icon(Iconsax.lock_outline),
          title: Text('${'lock'.tr} ${general.name}'),
          subtitle: Text('exit_and_lock_app'.tr),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        ExpansionTile(
          title: Text('danger_zone'.tr),
          subtitle: Text('delete_purge_or_reset_your_data'.tr),
          leading: const Icon(Iconsax.warning_2_outline),
          childrenPadding: const EdgeInsets.only(left: 20),
          children: [
            ListTile(
              iconColor: Colors.amber,
              leading: const Icon(Iconsax.refresh_outline),
              title: Text('${'purge'.tr} Items'),
              subtitle: Text('clear_all_items_and_start_over'.tr),
              onTap: controller.purge,
            ),
            ListTile(
              iconColor: const Color(0xFFFF7300),
              leading: const Icon(Iconsax.refresh_outline),
              title: Text('${'reset'.tr} ${general.name}'),
              subtitle: Text('delete_local_vault_and_logout'.tr),
              onTap: controller.reset,
              onLongPress: () => Utils.adaptiveRouteOpen(name: Routes.debug),
            ),
            if (AppPersistence.to.canShare) ...[
              ListTile(
                iconColor: Colors.red,
                leading: const Icon(Iconsax.warning_2_outline),
                title: Text('delete_remote_data'.tr),
                subtitle: Text('delete_remote_vault_and_files'.tr),
                onTap: controller.unsync,
              ),
            ],
          ],
        ),
        if (kDebugMode ||
            SecretPersistence.to.walletAddress.val ==
                '0x5b858485d6d086ce3c97408ebc423a36b9a6f81c') ...[
          const Divider(),
          ListTile(
            leading: const Icon(Iconsax.code_outline),
            trailing: const Icon(Iconsax.arrow_right_3_outline),
            title: const Text('Debugging'),
            onTap: () => Utils.adaptiveRouteOpen(name: Routes.debug),
          ),
        ],
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
            child: Text('need_help'.tr),
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
