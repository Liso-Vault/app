import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../utils/styles.dart';

class PhoneFieldParser {
  static TextFormField parse(HiveLisoField field) {
    return TextFormField(
      controller: TextEditingController(text: field.data['value']),
      keyboardType: TextInputType.phone,
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
        hintText: field.data['hint'],
      ),
    );
  }
}
