import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../utils/styles.dart';

// TODO: use flutter_quill package
// ignore: must_be_immutable
class RichTextFormField extends StatelessWidget {
  final HiveLisoField field;
  RichTextFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? controller;

  String get value => controller!.text;

  @override
  Widget build(BuildContext context) {
    controller = TextEditingController(text: field.data['value']);

    return TextFormField(
      controller: controller,
      maxLines: 5,
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
        hintText: field.data['hint'],
      ),
    );
  }
}
