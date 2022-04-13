import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/passphrase.card.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../general/segmented_item.widget.dart';
import 'import_screen.controller.dart';

class ImportScreen extends GetView<ImportScreenController> with ConsoleMixin {
  const ImportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LineIcons.fileImport, size: 100, color: kAppColor),
          const SizedBox(height: 20),
          Text(
            'import_vault'.tr,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 15),
          const Text(
            "Import your vault and enter your master seed phrase to decrypt it.\nMake sure you're in a safe location from prying eyes.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Obx(
            () => CupertinoSegmentedControl<ImportMode>(
              groupValue: controller.importMode.value,
              onValueChanged: (value) => controller.importMode.value = value,
              children: const {
                ImportMode.file: SegmentedControlItem(
                  text: 'File',
                  iconData: LineIcons.file,
                ),
                ImportMode.ipfs: SegmentedControlItem(
                  text: 'IPFS',
                  iconData: LineIcons.cube,
                ),
              },
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => controller.importMode() == ImportMode.file
                ? Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.filePathController,
                          validator: (text) =>
                              text!.isEmpty ? 'Import your vault file' : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            hintText: 'Path to your vault file',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LineIcons.upload),
                        onPressed: controller.importFile,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.ipfsUrlController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (data) => Utils.validateUri(data!),
                          decoration: InputDecoration(
                            labelText: 'server_url'.tr,
                            hintText: 'http://127.0.0.1:5001',
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !controller.ipfsBusy(),
                        child: IconButton(
                          onPressed: controller.checkIPFS,
                          icon: const Icon(LineIcons.vial),
                        ),
                        replacement: const BusyIndicator(),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          PassphraseCard(controller: controller.seedController),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: controller.continuePressed,
            label: Text('continue'.tr),
            icon: const Icon(LineIcons.arrowRight),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(centerTitle: false),
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
