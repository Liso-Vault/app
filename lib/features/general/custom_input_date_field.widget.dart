import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/utils/globals.dart';

class CustomInputDateField extends StatelessWidget with ConsoleMixin {
  final DateTime? initialDate;
  final String? label;
  final String? hint;
  final TextEditingController? controller;

  const CustomInputDateField({
    Key? key,
    required this.initialDate,
    required this.controller,
    this.label,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstDate = DateTime(1900, 1, 1);
    final lastDate = DateTime(DateTime.now().year + 100, 1, 1);

    // dd/MM/yyy format with leap year support
    bool hasMatch(String? value, String pattern) =>
        (value == null) ? false : RegExp(pattern).hasMatch(value);

    bool isDate(String s) => hasMatch(s,
        r'^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$');

    return TextFormField(
      controller: controller,
      validator: (data) =>
          data!.isEmpty || isDate(data) ? null : 'Invalid Date',
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        inputFormatterRestrictSpaces,
        // dd/MM/yyyy date format only
        FilteringTextInputFormatter.allow(RegExp("[0-9/]"))
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(
          padding: const EdgeInsets.only(right: 10),
          icon: const Icon(Iconsax.calendar),
          onPressed: () async {
            final newInitialDate = DateTime.tryParse(controller!.text) ??
                initialDate ??
                DateTime.now();

            final pickedDate = await showDatePicker(
              context: context,
              initialDate: newInitialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );

            if (pickedDate != null) {
              controller!.text = DateFormat('dd/MM/yyyy').format(pickedDate);
            }
          },
        ),
      ),
    );
  }
}
