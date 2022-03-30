import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../custom_widgets/custom_dropdown.field.dart';
import '../../data/genders.dart';

class GenderFieldParser {
  static CustomDropDownFormField parse(HiveLisoField field) {
    final items = kGenders
        .map((e) => DropdownMenuItem(child: Text(e), value: e))
        .toList();

    return CustomDropDownFormField(
      field: field,
      items: items,
    );
  }
}
