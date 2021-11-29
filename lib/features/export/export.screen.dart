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
        const Icon(LineIcons.alternateShield, size: 100),
        const SizedBox(height: 20),
        const Text(
          'Export Vault File',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
        const Text(
          "You'll be prompted to save a (xxx.liso) file. Please store it safely in an offline location",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 15),
        const Text(
          "Remember, your master mnemonic seed phrase that you backed up is the only key to decrypt your vault file",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: controller.passwordController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: controller.onChanged,
          onFieldSubmitted: (text) => controller.unlock(),
          decoration: Styles.inputDecoration.copyWith(
            hintText: 'Vault Password',
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => TextButton.icon(
            label: const Text('Export'),
            icon: const Icon(LineIcons.upload),
            onPressed: controller.canProceed() ? controller.unlock : null,
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            '${controller.attemptsLeft()} attempts left',
            style: const TextStyle(color: Colors.grey),
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
              onLoading: const BusyIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
