import 'package:flutter/material.dart';
import 'package:liso/core/data/countries.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/general/custom_dropdown.field.dart';

// ignore: must_be_immutable
class CountryFormField extends StatelessWidget {
  final HiveLisoField field;
  CountryFormField(this.field, {Key? key}) : super(key: key);

  CustomDropDownFormField? dropdown;

  String get value => dropdown!.value!;

  @override
  Widget build(BuildContext context) {
    final items = kCountriesMap
        .map((e) => DropdownMenuItem(
              child: Text(e['name']!),
              value: e['code'],
            ))
        .toList();

    dropdown = CustomDropDownFormField(field, items: items);
    return dropdown!;
  }
}
