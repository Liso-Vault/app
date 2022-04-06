import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';

import 'export_screen.controller.dart';

class ExportScreen extends GetView<ExportScreenController> with ConsoleMixin {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LineIcons.fileExport, size: 100, color: kAppColor),
        const SizedBox(height: 20),
        const Text(
          'Export Vault File',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
        const Text(
          "You'll be prompted to save a (xxx.liso) file. Please store it offline or in a secure digital cloud storage",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 15),
        const Text(
          "Remember, your master mnemonic seed phrase that you backed up is the only key to decrypt your vault file",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          label: Text('export'.tr),
          icon: const Icon(LineIcons.upload),
          onPressed: controller.unlock,
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            '${controller.attemptsLeft()} ' + 'attempts_left'.tr,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
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
              (_) => SingleChildScrollView(child: content),
              onLoading: Obx(
                () => BusyIndicator(
                  message: controller.busyMessage.value,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
