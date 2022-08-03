import 'package:flutter/material.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:get/get.dart';

import '../../../core/hive/models/item.hive.dart';
import '../../../core/utils/utils.dart';
import 'autofill_picker_dialog.controller.dart';

class AutofillPickerDialog extends StatelessWidget {
  final HiveLisoItem item;
  const AutofillPickerDialog({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AutofillPickerDialogController());
    controller.item = item;
    controller.load();

    Widget _itemBuilder(_, index) {
      final field = controller.data[index];

      void _done() {
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

      void _select() {
        if (controller.mode.value == AutofillPickerMode.username) {
          controller.username = field.data.value!;

          if (item.passwordFields.length <= 1) {
            controller.password = item.passwordFields.first.data.value!;
            return _done();
          }

          // change to password mode
          controller.data.clear();
          controller.mode.value = AutofillPickerMode.password;
          controller.load();
        } else {
          controller.password = field.data.value!;
          return _done();
        }
      }

      return ListTile(
        title: Text(field.data.label!),
        subtitle: Text(field.data.value!),
        onTap: _select,
      );
    }

    final content = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: _itemBuilder,
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
      content: Utils.isDrawerExpandable
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
