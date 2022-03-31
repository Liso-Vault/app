import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../custom_widgets/custom_dropdown.field.dart';
import '../data/genders.dart';

// ignore: must_be_immutable
class GenderFormField extends StatelessWidget {
  final HiveLisoField field;
  GenderFormField(this.field, {Key? key}) : super(key: key);

  CustomDropDownFormField? dropdown;

  String get value => dropdown!.value!;

  @override
  Widget build(BuildContext context) {
    final items = kGendersMap
        .map((e) => DropdownMenuItem(
              child: Text(e['name']!),
              value: e['code'],
            ))
        .toList();

    dropdown = CustomDropDownFormField(field, items: items);
    return dropdown!;
  }
}
