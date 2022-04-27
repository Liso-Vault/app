import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/firebase/config/config.service.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import 'settings_screen.controller.dart';

class SettingsScreen extends GetWidget<SettingsScreenController>
    with ConsoleMixin {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              leading: const Icon(LineIcons.adjust),
              trailing: const Icon(LineIcons.angleRight),
              title: Text('theme'.tr),
              subtitle: Obx(() => Text(controller.theme().tr)),
            ),
          ),
        ),
        const Divider(),
        SimpleBuilder(
          builder: (context) {
            return ContextMenuButton(
              controller.menuItemsSyncSetting,
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(LineIcons.cloud),
                trailing: const Icon(LineIcons.angleRight),
                title: Text('${ConfigService.to.appName} Cloud Sync'),
                subtitle: Text(
                  PersistenceService.to.sync.val ? 'On' : 'Off',
                  style: TextStyle(
                    color: PersistenceService.to.sync.val ? kAppColor : null,
                  ),
                ),
                onTap: () => Utils.adaptiveRouteOpen(name: Routes.syncSettings),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          title: Text('time_machine'.tr),
          subtitle: const Text('Go back in time to undo your changes'),
          leading: const Icon(LineIcons.clock),
          trailing: const Icon(LineIcons.angleRight),
          onTap: () {
            if (!PersistenceService.to.sync.val) {
              return UIUtils.showSimpleDialog(
                'Sync Required',
                'Please turn on ${ConfigService.to.appName} Cloud Sync to use this feature',
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
          leading: const Icon(LineIcons.box),
          trailing: const Icon(LineIcons.fileUpload),
          title: Text('export_vault'.tr),
          subtitle: const Text('Save <vault>.liso to an external source'),
          onTap: () => Utils.adaptiveRouteOpen(name: Routes.export),
          enabled: controller.canExportVault,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.wallet),
          trailing: const Icon(LineIcons.fileUpload),
          title: Text('export_wallet'.tr),
          subtitle: const Text('Save <wallet>.json to an external source'),
          onTap: controller.exportWallet,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.download),
          trailing: const Icon(LineIcons.angleRight),
          title: const Text('Import Items'),
          subtitle: const Text('Import items from external sources'),
          // enabled: false,
          onTap: () {
            UIUtils.showSnackBar(
              title: 'Test',
              message: 'Message',
              seconds: 2,
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.key),
          trailing: const Icon(LineIcons.exclamationTriangle),
          title: const Text('Show Seed Phrase'),
          subtitle: const Text('Make sure you are in a safe location'),
          onTap: controller.showSeed,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.lock),
          trailing: const Icon(LineIcons.doorOpen),
          title: Text('lock'.tr + ' ${ConfigService.to.appName}'),
          subtitle: const Text('Exit and lock the app'),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.trashRestore),
          trailing: const Icon(LineIcons.exclamationTriangle),
          title: Text('reset'.tr + ' ${ConfigService.to.appName}'),
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
