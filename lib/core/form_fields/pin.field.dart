import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/items/item_screen.controller.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';
import '../utils/globals.dart';
import '../utils/utils.dart';

class PINFormField extends StatefulWidget {
  final HiveLisoField field;
  final TextEditingController fieldController;
  final bool enabled;

  const PINFormField(
    this.field, {
    Key? key,
    required this.fieldController,
    this.enabled = true,
  }) : super(key: key);

  String get value => fieldController.text;
  bool get isPasswordField => field.identifier != 'private_key';

  @override
  State<PINFormField> createState() => _PINFormFieldState();
}

class _PINFormFieldState extends State<PINFormField> {
  // VARIABLES
  bool obscureText = true;

  // GETTERS
  dynamic get formWidget => ItemScreenController.to.widgets.firstWhere((e) =>
      (e as dynamic).children.first.child.field.identifier ==
      widget.field.identifier);

  HiveLisoField get formField => formWidget.children.first.child.field;

  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: obscureText ? 'Show' : 'Hide',
        onSelected: () => setState(() {
          obscureText = !obscureText;
        }),
        leading: Icon(
          obscureText ? Iconsax.eye : Iconsax.eye_slash,
        ),
      ),
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

  // FUNCTIONS

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: widget.fieldController,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscureText,
      readOnly: widget.field.readOnly,
      inputFormatters: [
        inputFormatterRestrictSpaces,
        inputFormatterNumericOnly,
      ],
      validator: (data) => data!.isEmpty || GetUtils.isNumericOnly(data)
          ? null
          : 'Not a numeric PIN',
      onChanged: (value) => setState(() {}),
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
