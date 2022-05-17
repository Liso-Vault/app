import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/hive/hive.manager.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import 'settings_screen.controller.dart';

class SettingsScreen extends GetWidget<SettingsScreenController>
    with ConsoleMixin {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final persistence = Get.find<PersistenceService>();
    final config = Get.find<ConfigService>();

    final listView = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const Divider(),
        Obx(
          () => ContextMenuButton(
            controller.menuItemsTheme,
            useMouseRegion: true,
            padding: EdgeInsets.zero,
            initialItem: controller.menuItemsTheme.firstWhere(
              (e) => e.title.toLowerCase() == controller.theme.value,
            ),
            child: ListTile(
              leading: const Icon(Iconsax.color_swatch),
              trailing: const Icon(Iconsax.arrow_right_3),
              title: Text('theme'.tr),
              subtitle: Obx(() => Text(controller.theme().tr)),
            ),
          ),
        ),
        const Divider(),
        SimpleBuilder(
          builder: (context) {
            return Column(
              children: <Widget>[
                CheckboxListTile(
                  title: Text('${config.appName} Cloud Sync'),
                  subtitle: const Text("Keep in sync with all your devices"),
                  secondary: const Icon(Iconsax.cloud),
                  value: persistence.sync.val,
                  onChanged: (value) => persistence.sync.val = value!,
                ),
                const Divider(),
                CheckboxListTile(
                  title: const Text('Errors & Crashes'),
                  subtitle: const Text("Send anonymous crash & error reports"),
                  secondary: const Icon(Iconsax.cpu),
                  value: persistence.crashReporting.val,
                  onChanged: (value) => persistence.crashReporting.val = value!,
                ),
                const Divider(),
                CheckboxListTile(
                  title: const Text('Usage Statistics'),
                  subtitle: const Text('Send anonymous usage statistics'),
                  secondary: const Icon(Iconsax.chart_square),
                  value: persistence.analytics.val,
                  onChanged: (value) => persistence.analytics.val = value!,
                ),
              ],
            );
          },
        ),
        const Divider(),
        ListTile(
          title: Text('time_machine'.tr),
          subtitle: const Text('Go back in time to undo your changes'),
          leading: const Icon(Iconsax.clock),
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
          leading: const Icon(Iconsax.import_1),
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
          leading: const Icon(Iconsax.box_1),
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
          leading: const Icon(Iconsax.wallet_1),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('export_wallet'.tr),
          subtitle: const Text('Save <wallet>.json to an external source'),
          onTap: controller.exportWallet,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Iconsax.key),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: const Text('Show Seed Phrase'),
          subtitle: const Text('Make sure you are in a safe location'),
          onTap: controller.showSeed,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Iconsax.lock),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${'lock'.tr} ${config.appName}'),
          subtitle: const Text('Exit and lock the app'),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Iconsax.refresh5),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${'reset'.tr} ${config.appName}'),
          subtitle: const Text('Delete local vault and start over'),
          onTap: () => Utils.adaptiveRouteOpen(name: Routes.reset),
        ),
        const Divider(),
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
