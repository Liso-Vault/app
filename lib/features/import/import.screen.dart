import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';

import 'import_screen.controller.dart';

class ImportScreen extends GetView<ImportScreenController> with ConsoleMixin {
  const ImportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LineIcons.alternateShield, size: 100),
        const SizedBox(height: 20),
        const Text(
          'Import Vault File',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
        const Text(
          "Import your vault file and enter your master seed phrase to decrypt it",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
        controller.passphraseCard,
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                enabled: false,
                controller: controller.filePathController,
                validator: (text) =>
                    text!.isEmpty ? 'Import your vault file' : '',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: Styles.inputDecoration.copyWith(
                  hintText: 'Path to your vault file',
                ),
              ),
            ),
            IconButton(
              onPressed: controller.importFile,
              icon: const Icon(LineIcons.upload),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: controller.continuePressed,
          label: const Text('Continue'),
          icon: const Icon(LineIcons.arrowRight),
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
