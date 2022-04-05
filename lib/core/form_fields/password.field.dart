import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../utils/styles.dart';

// ignore: must_be_immutable
class PasswordFormField extends GetWidget<PasswordFormFieldController> {
  final HiveLisoField field;
  PasswordFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? fieldController;

  String get value => fieldController!.text;

  @override
  Widget build(BuildContext context) {
    fieldController = TextEditingController(text: field.data['value']);

    return Obx(
      () => TextFormField(
        controller: fieldController,
        keyboardType: TextInputType.visiblePassword,
        obscureText: controller.obscureText.value,
        decoration: Styles.inputDecoration.copyWith(
          labelText: field.data['label'],
          hintText: field.data['hint'],
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscureText.value ? LineIcons.eye : LineIcons.eyeSlash,
            ),
            onPressed: controller.obscureText.toggle,
          ),
        ),
      ),
    );
  }
}

class PasswordFormFieldController extends GetxController {
  final obscureText = false.obs;
}
