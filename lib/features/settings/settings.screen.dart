import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/resources/resources.dart';

import '../../core/liso/liso.manager.dart';
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
        ListTile(
          leading: Image.asset(Images.logo, height: 25, color: Colors.grey),
          trailing: const Icon(LineIcons.copy),
          title: const Text('Liso Address'),
          subtitle: Text(LisoManager.walletAddress),
          onTap: () => Utils.copyToClipboard(LisoManager.walletAddress),
        ),
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
        // const Divider(),
        // ListTile(
        //   leading: const Icon(LineIcons.cube),
        //   trailing: const Icon(LineIcons.angleRight),
        //   title: const Text('IPFS Configuration'),
        //   subtitle: Obx(() => Text(controller.ipfsServerUrl.value)),
        //   onTap: () async {
        //     await Utils.adaptiveRouteOpen(name: Routes.ipfs);
        //     controller.ipfsServerUrl.value =
        //         PersistenceService.to.ipfsServerUrl;
        //   },
        // ),
        const Divider(),
        SimpleBuilder(
          builder: (context) {
            return ListTile(
              leading: const Icon(LineIcons.cloud),
              trailing: const Icon(LineIcons.angleRight),
              title: const Text('Cloud Sync'),
              subtitle: Text(PersistenceService.to.sync.val ? 'On' : 'Off'),
              onTap: () => Utils.adaptiveRouteOpen(name: Routes.sync),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.lock),
          trailing: const Icon(LineIcons.doorOpen),
          title: Text('lock'.tr + ' $kAppName'),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        // TODO: Change Password is same as Import Vault
        // Remind user to backup first, then reset,
        // const Divider(),
        // ListTile(
        //   leading: const Icon(LineIcons.download),
        //   trailing: const Icon(LineIcons.angleRight),
        //   title: Text('import_vault'.tr),
        //   // TODO: reset vault before importing
        //   // TODO: show warning that it will reset before importing
        //   // onTap: () => Get.toNamed(Routes.import),
        // ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.box),
          trailing: const Icon(LineIcons.fileUpload),
          title: Text('export_vault'.tr),
          onTap: () => Utils.adaptiveRouteOpen(name: Routes.export),
          enabled: controller.canExportVault,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.wallet),
          trailing: const Icon(LineIcons.fileUpload),
          title: Text('export_wallet'.tr),
          onTap: controller.exportWallet,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.alternateShield),
          trailing: const Icon(LineIcons.infoCircle),
          title: const Text('Change Password'),
          onTap: controller.changePassword,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.trashRestore),
          trailing: const Icon(LineIcons.exclamationTriangle),
          title: Text('reset'.tr + ' $kAppName'),
          onTap: () => Utils.adaptiveRouteOpen(name: Routes.reset),
        ),
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
