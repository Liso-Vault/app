import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';

import 'import_screen.controller.dart';

class ImportScreen extends GetView<ImportScreenController> with ConsoleMixin {
  const ImportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Container(
            constraints: Styles.containerConstraints,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LineIcons.alternateShield, size: 100),
                const SizedBox(height: 20),
                const Text(
                  'Import Vault',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Import your updated vault file",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                // const SizedBox(height: 30),
                // controller.passphraseCard,
                // const SizedBox(height: 10),
                // TextButton.icon(
                //   onPressed: controller.importPhrase,
                //   label: const Text('Continue'),
                //   icon: const Icon(LineIcons.arrowRight),
                // ),
                const Divider(height: 20),
                TextButton.icon(
                  onPressed: controller.importFile,
                  label: const Text('Import Vault File'),
                  icon: const Icon(LineIcons.download),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
