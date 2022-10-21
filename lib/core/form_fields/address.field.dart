import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/form_fields/choices.field.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/core/utils/globals.dart';

import '../../features/general/section.widget.dart';
import '../../features/items/item_screen.controller.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';
import '../utils/utils.dart';

// ignore: must_be_immutable
class AddressFormField extends StatefulWidget with ConsoleMixin {
  final HiveLisoField field;
  final TextEditingController street1Controller;
  final TextEditingController street2Controller;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController zipController;
  final ChoicesFormField countryFormField;

  final bool readOnly;

  AddressFormField(
    this.field, {
    Key? key,
    this.readOnly = false,
    required this.street1Controller,
    required this.street2Controller,
    required this.cityController,
    required this.stateController,
    required this.zipController,
    required this.countryFormField,
  }) : super(key: key);

  Map<String, dynamic> get value {
    return {
      'street1': street1Controller.text,
      'street2': street2Controller.text,
      'city': cityController.text,
      'state': stateController.text,
      'zip': zipController.text,
      'country': countryFormField.dropdown!.value,
    };
  }

  @override
  State<AddressFormField> createState() => _AddressFormFieldState();
}

class _AddressFormFieldState extends State<AddressFormField> {
  // GETTERS
  dynamic get formWidget => ItemScreenController.to.widgets.firstWhere((e) =>
      (e as dynamic).children.first.child.field.identifier ==
      widget.field.identifier);

  HiveLisoField get formField => formWidget.children.first.child.field;

  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: 'Copy',
        leading: Icon(Iconsax.copy, size: popupIconSize),
        onSelected: () {
          final address = widget.value;
          final addressString =
              '${address['street1']}, ${address['street2']}, ${address['city']}, ${address['state']}, ${address['zip']}, ${address['country']}';
          Utils.copyToClipboard(addressString);
        },
      ),
      if (!widget.field.readOnly) ...[
        ContextMenuItem(
          title: 'Clear',
          leading: Icon(LineIcons.times, size: popupIconSize),
          onSelected: () {
            widget.street1Controller.clear();
            widget.street2Controller.clear();
            widget.cityController.clear();
            widget.stateController.clear();
            widget.zipController.clear();
            widget.countryFormField.clear();
          },
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
          onSelected: () => ItemScreenController.to.widgets.remove(
            formWidget,
          ),
        ),
      ]
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Section(text: widget.field.data.label!)),
              ContextMenuButton(
                menuItems,
                child: const Icon(LineIcons.verticalEllipsis),
              )
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.street1Controller,
            keyboardType: TextInputType.streetAddress,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Street 1'),
            readOnly: widget.field.readOnly || widget.readOnly,
            autofillHints: const [AutofillHints.streetAddressLine1],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.street2Controller,
            keyboardType: TextInputType.streetAddress,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Street 2'),
            readOnly: widget.field.readOnly || widget.readOnly,
            autofillHints: const [AutofillHints.streetAddressLine2],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.cityController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'City'),
            readOnly: widget.field.readOnly || widget.readOnly,
            autofillHints: const [AutofillHints.addressCity],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.stateController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'State / Province'),
            readOnly: widget.field.readOnly || widget.readOnly,
            autofillHints: const [AutofillHints.addressState],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.zipController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Zip Code'),
            readOnly: widget.field.readOnly || widget.readOnly,
            autofillHints: const [AutofillHints.postalCode],
          ),
          const SizedBox(height: 10),
          widget.countryFormField,
        ],
      ),
    );
  }
}
