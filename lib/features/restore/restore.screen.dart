import 'package:app_core/firebase/config.service.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:liso/features/seed/seed_field.widget.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/styles.dart';
import '../general/segmented_item.widget.dart';
import 'restore_screen.controller.dart';

class RestoreScreen extends StatelessWidget with ConsoleMixin {
  const RestoreScreen({super.key});

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
            Icon(Iconsax.import_1_outline, size: 150, color: themeColor),
            const SizedBox(height: 20),
            Text(
              'restore_vault'.tr,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "restore_your_vault_with_your_master_seed_phrase_to_decrypt_it"
                  .tr,
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
                    text: '${general.name} Cloud',
                    iconData: Iconsax.cloud_outline,
                  ),
                  RestoreMode.file: SegmentedControlItem(
                    text: 'vault_file'.tr,
                    iconData: Iconsax.document_code_outline,
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
                        text!.isEmpty ? 'import_your_vault_file'.tr : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      hintText:
                          '${'path_to_your_file'.tr} (<vault>.$kVaultExtension)',
                      label: Text('vault_file_path'.tr),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: IconButton(
                          icon: const Icon(Iconsax.import_1_outline),
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
            ElevatedButton.icon(
              onPressed: controller.continuePressed,
              label: Text('continue'.tr),
              icon: const Icon(Iconsax.arrow_circle_right_outline),
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
            child: Text('need_help'.tr),
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
