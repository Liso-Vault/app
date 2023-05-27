import 'package:app_core/config/app.model.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/features/seed/seed_field.widget.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/styles.dart';
import '../general/segmented_item.widget.dart';
import 'restore_screen.controller.dart';

class RestoreScreen extends StatelessWidget with ConsoleMixin {
  const RestoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RestoreScreenController());

    final content = Container(
      constraints: Styles.containerConstraints,
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.import_1, size: 150, color: themeColor),
            const SizedBox(height: 20),
            Text(
              'restore_vault'.tr,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
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
                    text: '${appConfig.name} Cloud',
                    iconData: Iconsax.cloud,
                  ),
                  RestoreMode.file: const SegmentedControlItem(
                    text: 'Vault File',
                    iconData: Iconsax.document_code,
                  ),
                },
              ),
            ),
            const SizedBox(height: 30),
            Obx(() {
              if (controller.restoreMode.value == RestoreMode.file) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: controller.filePathController,
                    validator: (text) =>
                        text!.isEmpty ? 'Import your vault file' : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      hintText: 'Path to your <vault>.$kVaultExtension file',
                      label: const Text('Vault File Path'),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: IconButton(
                          icon: const Icon(Iconsax.import_1),
                          onPressed: controller.importFile,
                        ),
                      ),
                    ),
                  ),
                );
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
      ),
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: Obx(
          () => Visibility(
            visible: !controller.busy.value,
            child: const AppBarLeadingButton(),
          ),
        ),
        actions: [
          // Obx(
          //   () => Visibility(
          //     visible: !controller.busy.value,
          //     child: IconButton(
          //       icon: const Icon(Iconsax.setting_3),
          //       onPressed: () =>
          //           Utils.adaptiveRouteOpen(name: Routes.syncProvider),
          //     ),
          //   ),
          // ),
          TextButton(
            onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
            child: const Text('Need Help ?'),
          ),
        ],
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
