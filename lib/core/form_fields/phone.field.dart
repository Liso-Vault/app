import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../utils/globals.dart';
import '../utils/styles.dart';

// ignore: must_be_immutable
class PhoneFormField extends StatelessWidget {
  final HiveLisoField field;
  PhoneFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? controller;

  String get value => controller!.text;

  @override
  Widget build(BuildContext context) {
    controller = TextEditingController(text: field.data['value']);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [inputFormatterRestrictSpaces],
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
        hintText: field.data['hint'],
      ),
    );
  }
}
