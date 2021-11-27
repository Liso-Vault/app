import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/reset/reset_screen.controller.dart';

class ResetScreen extends GetView<ResetScreenController> {
  const ResetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LineIcons.exclamationTriangle, size: 100),
        const SizedBox(height: 20),
        const Text(
          'Reset Vault',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        const Text(
          'All your data will be erased permanently. Make sure you have a backup of your vault before you proceed. Proceed with caution',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: Get.back,
              label: const Text('Cancel'),
              icon: const Icon(LineIcons.times),
            ),
            const SizedBox(width: 20),
            TextButton.icon(
              onPressed: controller.reset,
              label: const Text('Reset'),
              icon: const Icon(LineIcons.syncIcon),
              style: Styles.textButtonStyleNegative,
            ),
          ],
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15),
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
