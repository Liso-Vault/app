import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

class SectionFieldParser {
  static Widget parse(HiveLisoField field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        field.data['value'],
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.grey,
        ),
      ),
    );
  }
}
