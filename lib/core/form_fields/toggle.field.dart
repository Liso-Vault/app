import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/features/items/item_screen.controller.dart';

import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';

class ToggleFieldForm extends StatefulWidget {
  final HiveLisoField field;

  const ToggleFieldForm(
    this.field, {
    Key? key,
  }) : super(key: key);

  String get value => field.data.value!;

  @override
  State<ToggleFieldForm> createState() => _ToggleFieldFormState();
}

class _ToggleFieldFormState extends State<ToggleFieldForm> {
  // GETTERS
  dynamic get formWidget => ItemScreenController.to.widgets.firstWhere((e) =>
      (e as dynamic).children.first.child.child.field.identifier ==
      widget.field.identifier);

  HiveLisoField get formField => formWidget.children.first.child.field;

  List<ContextMenuItem> get menuItems {
    return [
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SwitchListTile(
            value: widget.field.data.value == 'true',
            title: Text(widget.field.data.label!),
            // contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                widget.field.data.value = value.toString();
              });
            },
          ),
        ),
        if (!widget.field.reserved) ...[
          ContextMenuButton(
            menuItems,
            child: const Icon(LineIcons.verticalEllipsis),
          )
        ],
      ],
    );
  }
}
