import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

class DateTimeFormField extends StatelessWidget {
  final HiveLisoField field;
  const DateTimeFormField(this.field, {super.key});

  // GETTERS
  String get value => '';

  @override
  Widget build(BuildContext context) {
    return const Text('Unimplemented Field');
  }
}
