import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/features/general/section.widget.dart';

class SectionFormField extends StatelessWidget {
  final HiveLisoField field;
  const SectionFormField(this.field, {Key? key}) : super(key: key);

  // GETTERS
  String get value => field.data.value!.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Section(text: value);
  }
}
