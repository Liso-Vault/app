import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../utils/globals.dart';

// ignore: must_be_immutable
class PINFormField extends GetWidget<PINFormFieldController> {
  final HiveLisoField field;
  PINFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? _fieldController;
  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data['value']);

    return Obx(
      () => TextFormField(
        controller: _fieldController,
        keyboardType: TextInputType.number,
        obscureText: controller.obscureText(),
        inputFormatters: [
          inputFormatterRestrictSpaces,
          inputFormatterNumericOnly,
        ],
        validator: (data) => data!.isEmpty || GetUtils.isNumericOnly(data)
            ? null
            : 'Not a numeric PIN',
        decoration: InputDecoration(
          labelText: field.data['label'],
          hintText: field.data['hint'],
          suffixIcon: IconButton(
            padding: const EdgeInsets.only(right: 10),
            onPressed: controller.obscureText.toggle,
            icon: Obx(
              () => Icon(
                controller.obscureText() ? LineIcons.eye : LineIcons.eyeSlash,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PINFormFieldController extends GetxController {
  final obscureText = true.obs;
}
