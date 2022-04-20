import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/passphrase.card.dart';

import '../../core/utils/globals.dart';
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
                ImportMode.liso: SegmentedControlItem(
                  text: '$kAppName Cloud',
                  iconData: LineIcons.cloud,
                ),
                ImportMode.file: SegmentedControlItem(
                  text: 'File',
                  iconData: LineIcons.archiveFile,
                ),
                // ImportMode.s3: SegmentedControlItem(
                //   text: 'S3',
                //   iconData: LineIcons.amazonWebServicesAws,
                // ),
                // ImportMode.ipfs: SegmentedControlItem(
                //   text: 'IPFS',
                //   iconData: LineIcons.cube,
                // ),
              },
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.importMode() == ImportMode.file) {
              return Row(
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
                    icon: const Icon(LineIcons.download),
                    onPressed: controller.importFile,
                  ),
                ],
              );
            } else if (controller.importMode() == ImportMode.liso) {
              return const Text(
                'Enter the seed phrase you used to sync to the Decentralized $kAppName Cloud Storage',
                textAlign: TextAlign.center,
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
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
            padding: const EdgeInsets.all(20),
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
