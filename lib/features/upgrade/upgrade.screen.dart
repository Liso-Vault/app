import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/ui_utils.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/globals.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import 'upgrade_screen.controller.dart';

class UpgradeScreen extends GetView<UpgradeScreenController> with ConsoleMixin {
  const UpgradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = Get.parameters['title']!;
    final body = Get.parameters['body']!;

    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            Icon(LineIcons.rocket, size: 150, color: themeColor),
            const SizedBox(height: 10),
            Text(
              '${ConfigService.to.appName} Pro',
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  UIUtils.showSimpleDialog(
                    'Upgrade to ${ConfigService.to.appName} Pro',
                    'This feature is coming soon',
                  );
                },
                child: const Text('Subscribe'),
              ),
            ),
          ],
        ),
      ),
    );

    final appBar = AppBar(
      leading: const AppBarLeadingButton(),
    );

    return Scaffold(
      appBar: appBar,
      body: controller.obx(
        (_) => content,
        onLoading: const BusyIndicator(),
      ),
    );
  }
}
