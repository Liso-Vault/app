import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../utils/styles.dart';

class EmailFieldParser {
  static TextFormField parse(HiveLisoField field) {
    // TODO: validator

    return TextFormField(
      controller: TextEditingController(text: field.data['value']),
      keyboardType: TextInputType.emailAddress,
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
        hintText: field.data['hint'],
      ),
    );
  }
}
