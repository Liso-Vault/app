import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/seed/seed_field.widget.dart';

// ignore: must_be_immutable
class SeedFormField extends StatelessWidget {
  final HiveLisoField field;
  SeedFormField(this.field, {Key? key}) : super(key: key);

  // VARIABLES
  final _fieldController = TextEditingController();

  // GETTERS
  String get value => _fieldController.text;

  @override
  Widget build(BuildContext context) {
    return SeedField(
      fieldController: _fieldController,
      initialValue: field.data.value ?? '',
      readOnly: field.readOnly,
      required: field.required,
    );
  }
}
