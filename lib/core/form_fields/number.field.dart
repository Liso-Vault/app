import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../utils/globals.dart';

// ignore: must_be_immutable
class NumberFormField extends StatelessWidget {
  final HiveLisoField field;
  NumberFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? _fieldController;
  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data['value']);

    return TextFormField(
      controller: _fieldController,
      keyboardType: TextInputType.number,
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
      ),
    );
  }
}
