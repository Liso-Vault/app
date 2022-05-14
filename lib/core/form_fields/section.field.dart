import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/features/general/section.widget.dart';

class SectionFormField extends StatelessWidget {
  final HiveLisoField field;
  const SectionFormField(this.field, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Section(text: field.data.value!.toUpperCase());
  }
}
