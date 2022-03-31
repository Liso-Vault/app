import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../utils/styles.dart';

// ignore: must_be_immutable
class PINFormField extends StatelessWidget {
  final HiveLisoField field;
  PINFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? controller;

  String get value => controller!.text;

  @override
  Widget build(BuildContext context) {
    controller = TextEditingController(text: field.data['value']);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
        hintText: field.data['hint'],
      ),
    );
  }
}
