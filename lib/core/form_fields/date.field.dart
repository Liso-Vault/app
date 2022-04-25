import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/core/utils/console.dart';

import '../../features/general/custom_input_date_field.widget.dart';

// ignore: must_be_immutable
class DateFormField extends StatelessWidget with ConsoleMixin {
  final HiveLisoField field;
  DateFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? _fieldController;
  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    DateTime? initialDate;

    try {
      initialDate = DateFormat('dd/MM/yyyy').parse(field.data['value']);
    } catch (e) {
      // empty date
    }

    _fieldController = TextEditingController(
        text: initialDate != null
            ? DateFormat('dd/MM/yyyy').format(initialDate)
            : '');

    return CustomInputDateField(
      controller: _fieldController,
      initialDate: initialDate,
      label: field.data['label'],
      hint: DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
  }
}
