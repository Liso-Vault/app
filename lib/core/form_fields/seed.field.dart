import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/seed/seed_field.widget.dart';

// ignore: must_be_immutable
class SeedFormField extends StatelessWidget {
  final HiveLisoField field;
  SeedFormField(this.field, {Key? key}) : super(key: key);

  // VARIABLES
  TextEditingController? _fieldController;

  // GETTERS
  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data.value ?? '');

    return SeedField(
      fieldController: _fieldController,
      readOnly: field.readOnly,
      required: field.required,
    );
  }
}
