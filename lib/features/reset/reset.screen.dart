import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/reset/reset_screen.controller.dart';

import '../../core/firebase/config/config.service.dart';

class ResetScreen extends GetView<ResetScreenController> {
  const ResetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LineIcons.exclamationTriangle, size: 100, color: Colors.red),
        const SizedBox(height: 20),
        Text(
          'reset'.tr + ' ${ConfigService.to.appName}',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        const Text(
          'Your local <vault>.$kVaultExtension will be deleted',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        const Text(
          "Make sure you have a backup of your vault file and master mnemonic seed phrase before you proceed",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: Get.back,
              label: Text('cancel'.tr),
              icon: const Icon(LineIcons.times),
            ),
            const SizedBox(width: 20),
            TextButton.icon(
              onPressed: controller.reset,
              label: Text('reset'.tr),
              icon: const Icon(LineIcons.trash),
              style: TextButton.styleFrom(primary: Colors.red),
            ),
          ],
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(leading: const AppBarLeadingButton()),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Container(
            constraints: Styles.containerConstraints,
            child: controller.obx(
              (_) => content,
              onLoading: const BusyIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
