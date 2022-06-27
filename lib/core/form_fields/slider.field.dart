import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/items/item_screen.controller.dart';

import '../../features/menu/menu.item.dart';

class SliderFieldForm extends StatefulWidget {
  final HiveLisoField field;

  const SliderFieldForm(
    this.field, {
    Key? key,
  }) : super(key: key);

  String get value => field.data.value!;

  @override
  State<SliderFieldForm> createState() => _SliderFieldFormState();
}

class _SliderFieldFormState extends State<SliderFieldForm> {
  // GETTERS
  dynamic get formWidget => ItemScreenController.to.widgets.firstWhere((e) =>
      (e as dynamic).children.first.child.field.identifier ==
      widget.field.identifier);

  HiveLisoField get formField => formWidget.children.first.child.field;

  List<ContextMenuItem> get menuItems {
    return [
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final min = double.tryParse(widget.field.data.extra!['min']) ?? 0.0;
    final max = double.tryParse(widget.field.data.extra!['max']) ?? 0.0;

    final labelString =
        '${widget.field.data.label!}: ${widget.field.data.value!}';

    final slider = Theme(
      data: Get.theme.copyWith(
        sliderTheme: Get.theme.sliderTheme.copyWith(
          overlayShape: SliderComponentShape.noOverlay,
        ),
      ),
      child: Slider(
        value: double.tryParse(widget.field.data.value!) ?? 0.0,
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        label: labelString,
        onChanged: (value) {
          setState(() {
            widget.field.data.value = value.toString();
          });
        },
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelString,
          style: TextStyle(fontSize: 12, color: themeColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: slider,
        ),
      ],
    );
  }
}
