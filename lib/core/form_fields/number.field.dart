import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/utils.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/items/item_screen.controller.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';
import '../utils/globals.dart';
import '../utils/utils.dart';

class NumberFormField extends StatefulWidget {
  final HiveLisoField field;
  final TextEditingController fieldController;
  final bool enabled;

  const NumberFormField(
    this.field, {
    Key? key,
    this.enabled = true,
    required this.fieldController,
  }) : super(key: key);

  String get value => fieldController.text;

  @override
  State<NumberFormField> createState() => _NumberFormFieldState();
}

class _NumberFormFieldState extends State<NumberFormField> {
  // GETTERS
  dynamic get formWidget => ItemScreenController.to.widgets.firstWhere((e) =>
      (e as dynamic).children.first.child.field.identifier ==
      widget.field.identifier);

  HiveLisoField get formField => formWidget.children.first.child.field;

  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: 'Copy',
        leading: const Icon(Iconsax.copy),
        onSelected: () => Utils.copyToClipboard(widget.fieldController.text),
      ),
      if (!widget.field.readOnly) ...[
        ContextMenuItem(
          title: 'Clear',
          leading: const Icon(LineIcons.times),
          onSelected: widget.fieldController.clear,
        ),
      ],
      if (!widget.field.reserved) ...[
        ContextMenuItem(
          title: 'Properties',
          leading: const Icon(Iconsax.setting),
          onSelected: () async {
            await ItemScreenController.to.showFieldProperties(formWidget);
            setState(() {});
          },
        ),
        ContextMenuItem(
          title: 'Remove',
          leading: const Icon(Iconsax.trash),
          onSelected: () => ItemScreenController.to.widgets.remove(formWidget),
        ),
      ]
    ];
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: widget.fieldController,
      readOnly: widget.field.readOnly,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        inputFormatterRestrictSpaces,
        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
      ],
      validator: (data) => data!.isEmpty || GetUtils.isNumericOnly(data)
          ? null
          : 'Invalid number',
      decoration: InputDecoration(
        labelText: widget.field.data.label,
        hintText: widget.field.data.hint,
        suffixIcon: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
      ),
    );
  }
}
