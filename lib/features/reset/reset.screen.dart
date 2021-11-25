import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/reset/reset_screen.controller.dart';

class ResetScreen extends GetView<ResetScreenController> {
  const ResetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: CenteredPlaceholder(
          iconData: LineIcons.exclamationTriangle,
          message:
              'All your vault data will be erased permanently. Make sure you have a backup of your master seed before you proceed',
          child: Row(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
