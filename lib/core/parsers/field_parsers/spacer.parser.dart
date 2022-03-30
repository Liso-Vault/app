import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

class SpacerFieldParser {
  static SizedBox parse(HiveLisoField field) {
    return const SizedBox(height: 10);
  }
}
