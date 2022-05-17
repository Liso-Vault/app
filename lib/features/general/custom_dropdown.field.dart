// ignore: must_be_immutable
import 'package:flutter/material.dart';

import '../../core/hive/models/field.hive.dart';

// ignore: must_be_immutable
class CustomDropDownFormField extends StatelessWidget {
  final List<DropdownMenuItem<dynamic>> items;
  final HiveLisoField field;

  CustomDropDownFormField(
    this.field, {
    Key? key,
    required this.items,
  }) : super(key: key);

  String? value;

  @override
  Widget build(BuildContext context) {
    // set initial value
    value = field.data.value;

    return DropdownButtonFormField<dynamic>(
      isExpanded: true, // fix for renderflex overflowed
      value: value,
      items: items,
      onChanged: (newValue) => value = newValue,
      decoration: InputDecoration(
        labelText: field.data.label,
        hintText: field.data.hint,
      ),
    );
  }
}
