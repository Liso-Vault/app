import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/features/general/section.widget.dart';

import '../../features/items/item_screen.controller.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';

class SectionFormField extends StatefulWidget {
  final HiveLisoField field;
  const SectionFormField(this.field, {Key? key}) : super(key: key);

  String get value => field.data.value!.toUpperCase();

  @override
  State<SectionFormField> createState() => _SectionFormFieldState();
}

class _SectionFormFieldState extends State<SectionFormField> {
  // GETTERS
  dynamic get formWidget => ItemScreenController.to.widgets.firstWhere((e) =>
      (e as dynamic).children.first.child.child.field.identifier ==
      widget.field.identifier);

  // HiveLisoField get formField => formWidget.children.first.child.field;

  List<ContextMenuItem> get menuItems {
    return [
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final section = Section(text: widget.field.sectionLabel);
    if (widget.field.reserved) return section;

    return Row(
      children: [
        Expanded(child: section),
        ContextMenuButton(
          menuItems,
          child: const Icon(LineAwesome.ellipsis_v_solid),
        ),
      ],
    );
  }
}
