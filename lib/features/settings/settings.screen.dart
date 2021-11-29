import 'package:flutter/foundation.dart';
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
          title: const Text('Lock Vault'),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.upload),
          trailing: const Icon(LineIcons.angleRight),
          title: const Text('Export Vault'),
          onTap: () => Get.toNamed(Routes.export),
          enabled: HiveManager.seeds!.isNotEmpty,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.syncIcon),
          trailing: const Icon(LineIcons.angleRight),
          title: const Text('Reset Vault'),
          onTap: () => Get.toNamed(Routes.reset),
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
      appBar: AppBar(title: const Text('Settings')),
      body: content,
    );
  }
}
