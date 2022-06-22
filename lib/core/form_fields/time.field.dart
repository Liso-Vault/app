import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

class TimeFormField extends StatelessWidget {
  final HiveLisoField field;
  const TimeFormField(this.field, {Key? key}) : super(key: key);

  // GETTERS
  String get value => '';

  @override
  Widget build(BuildContext context) {
    return const Text('Unimplemented Field');
  }
}
