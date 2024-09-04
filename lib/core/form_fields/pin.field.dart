import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/items/item_screen.controller.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';
import '../utils/globals.dart';

class PINFormField extends StatefulWidget {
  final HiveLisoField field;
  final TextEditingController fieldController;
  final bool enabled;

  const PINFormField(
    this.field, {
    super.key,
    required this.fieldController,
    this.enabled = true,
  });

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
      (e as dynamic).children.first.child.child.field.identifier ==
      widget.field.identifier);

  // HiveLisoField get formField => formWidget.children.first.child.field;

  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: obscureText ? 'Show' : 'Hide',
        onSelected: () => setState(() {
          obscureText = !obscureText;
        }),
        leading: Icon(
          obscureText ? Iconsax.eye_outline : Iconsax.eye_slash_outline,
          size: popupIconSize,
        ),
      ),
      ContextMenuItem(
        title: 'Copy',
        leading: Icon(Iconsax.copy_outline, size: popupIconSize),
        onSelected: () => Utils.copyToClipboard(widget.fieldController.text),
      ),
      if (!widget.field.readOnly) ...[
        ContextMenuItem(
          title: 'Clear',
          leading: Icon(LineAwesome.times_solid, size: popupIconSize),
          onSelected: widget.fieldController.clear,
        ),
      ],
      if (!widget.field.reserved) ...[
        ContextMenuItem(
          title: 'Properties',
          leading: Icon(Iconsax.setting_outline, size: popupIconSize),
          onSelected: () async {
            await ItemScreenController.to.showFieldProperties(formWidget);
            setState(() {});
          },
        ),
        ContextMenuItem(
          title: 'Remove',
          leading: Icon(Iconsax.trash_outline, size: popupIconSize),
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
          child: const Icon(LineAwesome.ellipsis_v_solid),
        ),
      ),
    );
  }
}
