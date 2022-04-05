import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../utils/globals.dart';
import '../utils/styles.dart';

// ignore: must_be_immutable
class EmailFormField extends StatelessWidget {
  final HiveLisoField field;
  EmailFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? controller;

  String get value => controller!.text;

  @override
  Widget build(BuildContext context) {
    controller = TextEditingController(text: field.data['value']);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: (data) =>
          data!.isEmpty || GetUtils.isEmail(data) ? null : 'Invalid Email',
      inputFormatters: [inputFormatterRestrictSpaces],
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
        hintText: field.data['hint'],
      ),
    );
  }
}
