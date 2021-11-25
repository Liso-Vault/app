import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/app/routes.dart';

import 'settings_screen.controller.dart';

class SettingsScreen extends GetView<SettingsScreenController>
    with ConsoleMixin {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _content = ListView(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      children: [
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.userSecret),
          trailing: const Icon(LineIcons.download),
          title: const Text('Dump Master Seed'),
          onTap: controller.dump,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.file),
          trailing: const Icon(LineIcons.upload),
          title: const Text('Export Master Seed'),
          onTap: controller.export,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.lock),
          trailing: const Icon(LineIcons.angleRight),
          title: const Text('Lock'),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.syncIcon),
          trailing: const Icon(LineIcons.angleRight),
          title: const Text('Reset'),
          onTap: () => Get.toNamed(Routes.reset),
        ),
        if (kDebugMode) ...[
          const Divider(),
          ListTile(
            title: const Text('Test'),
            leading: const Icon(LineIcons.play),
            onTap: () async {
              //
            },
          ),
        ],
        const Divider(),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _content,
    );
  }
}
