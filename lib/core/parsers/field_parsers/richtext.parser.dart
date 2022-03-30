import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../utils/styles.dart';

// TODO: use flutter_quill
class RichTextFieldParser {
  static TextFormField parse(HiveLisoField field) {
    return TextFormField(
      controller: TextEditingController(text: field.data['value']),
      maxLines: 5,
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
        hintText: field.data['hint'],
      ),
    );
  }
}
