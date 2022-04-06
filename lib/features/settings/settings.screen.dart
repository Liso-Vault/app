import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/resources/resources.dart';

import 'settings_screen.controller.dart';

class SettingsScreen extends GetView<SettingsScreenController>
    with ConsoleMixin {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final address = masterWallet!.privateKey.address.hexEip55;

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
          subtitle: Text(address),
          onTap: () => Utils.copyToClipboard(address),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.lock),
          trailing: const Icon(LineIcons.angleRight),
          title: Text('lock_vault'.tr),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.upload),
          trailing: const Icon(LineIcons.angleRight),
          title: Text('export_vault'.tr),
          onTap: () => Get.toNamed(Routes.export),
          enabled: HiveManager.items!.isNotEmpty,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.syncIcon),
          trailing: const Icon(LineIcons.angleRight),
          title: Text('reset_vault'.tr),
          onTap: () => Get.toNamed(Routes.reset),
        ),
        const Divider(),
        ListTile(
          title: const Text('Google Drive'),
          leading: const Icon(LineIcons.googleDrive),
          trailing: const Icon(LineIcons.angleRight),
          onTap: () => Get.offAndToNamed(Routes.signIn),
        ),
        const Divider(),
        // ListTile(
        //   leading: const Icon(LineIcons.alternateShield),
        //   trailing: const Icon(LineIcons.angleRight),
        //   title: const Text('Change Password'),
        //   onTap: () => Get.toNamed(Routes.export),
        // ),
        // const Divider(),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: content,
    );
  }
}
