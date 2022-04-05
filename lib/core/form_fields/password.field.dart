import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../utils/styles.dart';

// ignore: must_be_immutable
class PasswordFormField extends GetWidget<PasswordFormFieldController> {
  final HiveLisoField field;
  PasswordFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? _fieldController;

  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data['value']);

    return Column(
      children: [
        Obx(
          () => TextFormField(
            controller: _fieldController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: controller.obscureText.value,
            decoration: Styles.inputDecoration.copyWith(
              labelText: field.data['label'],
              hintText: field.data['hint'],
              suffixIcon: IconButton(
                onPressed: controller.obscureText.toggle,
                icon: Icon(
                  controller.obscureText.value
                      ? LineIcons.eye
                      : LineIcons.eyeSlash,
                ),
              ),
            ),
          ),
          // TODO: validator widget here
        ),
      ],
    );
  }
}

class PasswordFormFieldController extends GetxController {
  final obscureText = true.obs;
}
