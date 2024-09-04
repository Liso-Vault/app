import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:get/get.dart';

import '../../../core/hive/models/item.hive.dart';
import 'autofill_picker_dialog.controller.dart';

class AutofillPickerDialog extends StatelessWidget {
  final HiveLisoItem item;
  const AutofillPickerDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AutofillPickerDialogController());
    controller.item = item;
    controller.load();

    Widget itemBuilder(_, index) {
      final field = controller.data[index];

      void done() {
        Get.back(
          result: [
            PwDataset(
              label: item.title,
              username: controller.username,
              password: controller.password,
            )
          ],
        );
      }

      void select() {
        if (controller.mode.value == AutofillPickerMode.username) {
          controller.username = field.data.value!;

          if (item.passwordFields.length <= 1) {
            controller.password = item.passwordFields.first.data.value!;
            return done();
          }

          // change to password mode
          controller.data.clear();
          controller.mode.value = AutofillPickerMode.password;
          controller.load();
        } else {
          controller.password = field.data.value!;
          return done();
        }
      }

      return ListTile(
        title: Text(field.data.label!),
        subtitle: Text(field.data.value!),
        onTap: select,
      );
    }

    final content = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );

    return AlertDialog(
      title: Obx(
        () => Text(
          controller.mode.value == AutofillPickerMode.username
              ? 'Select Username'
              : 'Select Password',
        ),
      ),
      content: isSmallScreen
          ? content
          : Container(
              constraints: const BoxConstraints(maxHeight: 600),
              width: 400,
              child: content,
            ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
      ],
    );
  }
}
