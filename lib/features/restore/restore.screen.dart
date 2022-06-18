import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/persistence/persistence_builder.widget.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/seed/seed_field.widget.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/appbar_leading.widget.dart';
import '../general/segmented_item.widget.dart';
import 'restore_screen.controller.dart';

class RestoreScreen extends StatelessWidget with ConsoleMixin {
  const RestoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RestoreScreenController());

    final content = Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.import_1, size: 100, color: themeColor),
          const SizedBox(height: 20),
          Text(
            'restore_vault'.tr,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 5),
          const Text(
            "Restore your vault with your master seed phrase to decrypt it.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Obx(
            () => CupertinoSegmentedControl<RestoreMode>(
              groupValue: controller.restoreMode.value,
              onValueChanged: (value) => controller.restoreMode.value = value,
              children: {
                RestoreMode.cloud: SegmentedControlItem(
                  text: '${ConfigService.to.appName} Cloud',
                  iconData: Iconsax.cloud,
                ),
                RestoreMode.file: const SegmentedControlItem(
                  text: 'Liso File',
                  iconData: Iconsax.document_code,
                ),
              },
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.restoreMode.value == RestoreMode.file) {
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.filePathController,
                      validator: (text) =>
                          text!.isEmpty ? 'Select your vault file' : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        hintText: 'Path to your <vault>.$kVaultExtension file',
                        label: Text('Vault File Path'),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.import_1),
                    onPressed: controller.importFile,
                  ),
                ],
              );
            } else if (controller.restoreMode.value == RestoreMode.cloud) {
              return PersistenceBuilder(builder: (p, context) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => Utils.adaptiveRouteOpen(
                        name: Routes.syncProvider,
                      ),
                      child: Text('configure'.tr),
                    ),
                    const Divider(),
                  ],
                );
              });
            } else {
              return const SizedBox.shrink();
            }
          }),
          SeedField(
            fieldController: controller.seedController,
            onFieldSubmitted: (text) => controller.continuePressed(),
            showGenerate: false,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: controller.continuePressed,
              label: Text('continue'.tr),
              icon: const Icon(Iconsax.arrow_circle_right),
            ),
          ),
        ],
      ),
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: const AppBarLeadingButton(),
      ),
      body: controller.obx(
        (_) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ),
        onLoading: const BusyIndicator(),
      ),
    );

    return WillPopScope(
      onWillPop: () => controller.canPop,
      child: scaffold,
    );
  }
}
