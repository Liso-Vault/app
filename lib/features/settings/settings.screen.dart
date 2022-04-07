import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/resources/resources.dart';

import '../../core/utils/extensions.dart';
import '../general/busy_indicator.widget.dart';
import '../main/main_screen.controller.dart';
import 'settings_screen.controller.dart';

class SettingsScreen extends GetWidget<SettingsScreenController>
    with ConsoleMixin {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const Divider(),
        ListTile(
          leading: Image.asset(
            Images.logo,
            height: 25,
            color: Colors.grey,
          ),
          trailing: const Icon(LineIcons.copy),
          title: const Text('Liso Address'),
          subtitle: Text(masterWallet?.address ?? ''),
          onTap: () => Utils.copyToClipboard(masterWallet!.address),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.adjust),
          trailing: const Icon(LineIcons.angleRight),
          title: Text('theme'.tr),
          subtitle: Obx(() => Text(controller.theme().tr)),
          onTap: controller.selectTheme,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.lock),
          trailing: const Icon(LineIcons.angleRight),
          title: Text('lock'.tr + ' $kAppName'),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        // TODO: import vault from settings
        // const Divider(),
        // ListTile(
        //   leading: const Icon(LineIcons.download),
        //   trailing: const Icon(LineIcons.angleRight),
        //   title: Text('import_vault'.tr),
        //   onTap: () => Get.toNamed(Routes.import),
        // ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.box),
          trailing: const Icon(LineIcons.fileUpload),
          title: Text('export_vault'.tr),
          onTap: () => Get.toNamed(Routes.export),
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
          leading: const Icon(LineIcons.syncIcon),
          trailing: const Icon(LineIcons.exclamationTriangle),
          title: Text('reset'.tr + ' $kAppName'),
          onTap: () => Get.toNamed(Routes.reset),
        ),
        const Divider(),
        if (kDebugMode) ...[
          ListTile(
            title: const Text('Google Drive'),
            leading: const Icon(LineIcons.googleDrive),
            trailing: const Icon(LineIcons.angleRight),
            onTap: () => Get.offAndToNamed(Routes.signIn),
          ),
          const Divider(),
        ],
        // TODO: change vault password
        // ListTile(
        //   leading: const Icon(LineIcons.alternateShield),
        //   trailing: const Icon(LineIcons.angleRight),
        //   title: const Text('Change Password'),
        //   onTap: () => Get.toNamed(Routes.export),
        // ),
        // const Divider(),
        if (kDebugMode) ...[
          ListTile(
            leading: const Icon(LineIcons.bug),
            title: const Text('Window Size'),
            onTap: () async {
              final size = await DesktopWindow.getWindowSize();
              console.info('size: $size');
            },
          ),
        ],
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        // X icon for desktop instead of back for mobile
        leading: MainScreenController.to.expandableDrawer
            ? null
            : IconButton(
                onPressed: Get.back,
                icon: const Icon(LineIcons.times),
              ),
      ),
      body: controller.obx(
        (_) => content,
        onLoading: Obx(
          () => BusyIndicator(
            message: controller.busyMessage.value,
          ),
        ),
      ),
    );
  }
}
