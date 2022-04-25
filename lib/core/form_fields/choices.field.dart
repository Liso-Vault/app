import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/general/custom_dropdown.field.dart';

// ignore: must_be_immutable
class ChoicesFormField extends StatelessWidget {
  final HiveLisoField field;
  ChoicesFormField(this.field, {Key? key}) : super(key: key);

  CustomDropDownFormField? dropdown;
  String get value => dropdown!.value!;

  @override
  Widget build(BuildContext context) {
    final choices = field.data['choices'] as List<Map<String, dynamic>>;

    final items = choices
        .map((e) => DropdownMenuItem(
              child: Text(e['name']),
              value: e['value'],
            ))
        .toList();

    dropdown = CustomDropDownFormField(field, items: items);
    return dropdown!;
  }
}
