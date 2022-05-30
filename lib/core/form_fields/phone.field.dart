import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../utils/globals.dart';

// ignore: must_be_immutable
class PhoneFormField extends StatelessWidget {
  final HiveLisoField field;
  PhoneFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? _fieldController;

  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data.value);

    return TextFormField(
      controller: _fieldController,
      keyboardType: TextInputType.phone,
      readOnly: field.readOnly,
      inputFormatters: [inputFormatterRestrictSpaces],
      validator: (data) => data!.isEmpty || GetUtils.isPhoneNumber(data)
          ? null
          : 'Invalid phone number',
      decoration: InputDecoration(
        labelText: field.data.label,
        hintText: field.data.hint,
      ),
    );
  }
}
