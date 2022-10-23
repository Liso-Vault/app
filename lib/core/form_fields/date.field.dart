import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/items/item_screen.controller.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';
import '../utils/globals.dart';
import '../utils/utils.dart';

class DateFormField extends StatefulWidget {
  final HiveLisoField field;
  final TextEditingController fieldController;
  final DateTime? initialDate;
  final bool enabled;

  const DateFormField(
    this.field, {
    Key? key,
    this.enabled = true,
    required this.fieldController,
    this.initialDate,
  }) : super(key: key);

  String get value => fieldController.text;

  @override
  State<DateFormField> createState() => _DateFormFieldState();
}

class _DateFormFieldState extends State<DateFormField> {
  // GETTERS
  dynamic get formWidget => ItemScreenController.to.widgets.firstWhere((e) =>
      (e as dynamic).children.first.child.child.field.identifier ==
      widget.field.identifier);

  HiveLisoField get formField => formWidget.children.first.child.field;

  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: 'Copy',
        leading: Icon(Iconsax.copy, size: popupIconSize),
        onSelected: () => Utils.copyToClipboard(widget.fieldController.text),
      ),
      if (!widget.field.readOnly) ...[
        ContextMenuItem(
          title: 'Clear',
          leading: Icon(LineIcons.times, size: popupIconSize),
          onSelected: widget.fieldController.clear,
        ),
      ],
      if (!widget.field.reserved) ...[
        ContextMenuItem(
          title: 'Properties',
          leading: Icon(Iconsax.setting, size: popupIconSize),
          onSelected: () async {
            await ItemScreenController.to.showFieldProperties(formWidget);
            setState(() {});
          },
        ),
        ContextMenuItem(
          title: 'Remove',
          leading: Icon(Iconsax.trash, size: popupIconSize),
          onSelected: () => ItemScreenController.to.widgets.remove(formWidget),
        ),
      ]
    ];
  }

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
      controller: widget.fieldController,
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
        labelText: widget.field.data.label,
        hintText: widget.field.data.hint,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: const EdgeInsets.only(right: 10),
              icon: const Icon(Iconsax.calendar),
              onPressed: () async {
                final newInitialDate =
                    DateTime.tryParse(widget.fieldController.text) ??
                        widget.initialDate ??
                        DateTime.now();

                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: newInitialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );

                if (pickedDate != null) {
                  widget.fieldController.text =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                }
              },
            ),
            ContextMenuButton(
              menuItems,
              child: const Icon(LineIcons.verticalEllipsis),
            )
          ],
        ),
      ),
    );
  }
}
