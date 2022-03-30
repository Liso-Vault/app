import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../utils/styles.dart';

class TextAreaFieldParser {
  static TextFormField parse(HiveLisoField field) {
    return TextFormField(
      controller: TextEditingController(text: field.data['value']),
      minLines: 3,
      maxLines: 5,
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
        hintText: field.data['hint'],
      ),
    );
  }
}
