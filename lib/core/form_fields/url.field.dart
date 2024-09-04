import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/items/item_screen.controller.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';

class URLFormField extends StatefulWidget {
  final HiveLisoField field;
  final TextEditingController fieldController;
  final bool enabled;

  const URLFormField(
    this.field, {
    super.key,
    this.enabled = true,
    required this.fieldController,
  });

  String get value => fieldController.text;

  @override
  State<URLFormField> createState() => _URLFormFieldState();
}

class _URLFormFieldState extends State<URLFormField> {
  // GETTERS
  dynamic get formWidget => ItemScreenController.to.widgets.firstWhere((e) =>
      (e as dynamic).children.first.child.child.field.identifier ==
      widget.field.identifier);

  // HiveLisoField get formField => formWidget.children.first.child.field;

  List<ContextMenuItem> get menuItems {
    return [
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: widget.fieldController,
      readOnly: widget.field.readOnly,
      keyboardType: TextInputType.url,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: const [AutofillHints.url],
      validator: (data) {
        if (data!.isEmpty) return null;
        final uri = Uri.tryParse(data);
        if (uri != null && uri.isAbsolute) return null;
        return 'Invalid URI';
      },
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
