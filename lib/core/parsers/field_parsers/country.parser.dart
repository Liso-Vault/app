import 'package:flutter/material.dart';
import 'package:liso/core/data/countries.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../custom_widgets/custom_dropdown.field.dart';

class CountryFieldParser {
  static CustomDropDownFormField parse(HiveLisoField field) {
    final items = kCountriesMap
        .map((e) => DropdownMenuItem(
              child: Text(e['name']!),
              value: e['code'],
            ))
        .toList();

    return CustomDropDownFormField(
      field: field,
      items: items,
    );
  }
}
