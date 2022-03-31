// ignore: must_be_immutable
import 'package:flutter/material.dart';

import '../hive/models/field.hive.dart';
import '../utils/styles.dart';

// ignore: must_be_immutable
class CustomDropDownFormField extends StatelessWidget {
  final List<DropdownMenuItem<String>> items;
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
    value = field.data['value'];

    return DropdownButtonFormField<String>(
      isExpanded: true, // fix for renderflex overflowed
      value: field.data['value'],
      items: items,
      onChanged: (_value) => value = _value,
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
      ),
    );
  }
}