// ignore: must_be_immutable
import 'package:flutter/material.dart';

import '../hive/models/field.hive.dart';
import '../utils/styles.dart';

class CustomDropDownFormField extends StatelessWidget {
  final List<String> _valueArrayHolder = [''];
  final List<DropdownMenuItem<String>> items;
  final HiveLisoField field;

  CustomDropDownFormField({
    Key? key,
    required this.field,
    required this.items,
  }) : super(key: key);

  String get value => _valueArrayHolder.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true, // fix for renderflex overflowed
      value: field.data['value'],
      items: items,
      decoration: Styles.inputDecoration.copyWith(
        labelText: field.data['label'],
      ),
      onChanged: (_value) {
        _valueArrayHolder.clear();
        _valueArrayHolder.add(_value!);
      },
    );
  }
}
