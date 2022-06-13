import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:liso/core/form_fields/choices.field.dart';
import 'package:liso/core/form_fields/section.field.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:secrets/secrets.dart';

// ignore: must_be_immutable
class AddressFormField extends StatelessWidget with ConsoleMixin {
  final HiveLisoField field;
  AddressFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? _street1Controller;
  TextEditingController? _street2Controller;
  TextEditingController? _cityController;
  TextEditingController? _stateController;
  TextEditingController? _zipController;
  ChoicesFormField? _countryFormField;

  // TODO: Address Field JSON to Class
  Map<String, dynamic> get value {
    return {
      'street1': _street1Controller!.text,
      'street2': _street2Controller!.text,
      'city': _cityController!.text,
      'state': _stateController!.text,
      'zip': _zipController!.text,
      'country': _countryFormField!.dropdown!.value,
    };
  }

  @override
  Widget build(BuildContext context) {
    final extra = field.data.extra!;

    _street1Controller = TextEditingController(text: extra['street1']);
    _street2Controller = TextEditingController(text: extra['street2']);
    _cityController = TextEditingController(text: extra['city']);
    _stateController = TextEditingController(text: extra['state']);
    _zipController = TextEditingController(text: extra['zip']);

    _countryFormField = ChoicesFormField(
      HiveLisoField(
        type: LisoFieldType.choices.name,
        data: HiveLisoFieldData(
          value: extra['country'],
          label: 'Country',
          choices: List<HiveLisoFieldChoices>.from(
            Secrets.countries.map((x) => HiveLisoFieldChoices.fromJson(x)),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionFormField(
          HiveLisoField(
            type: '',
            data: HiveLisoFieldData(value: field.data.label),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _street1Controller,
          keyboardType: TextInputType.streetAddress,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Street 1'),
          readOnly: field.readOnly,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _street2Controller,
          keyboardType: TextInputType.streetAddress,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Street 2'),
          readOnly: field.readOnly,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _cityController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'City'),
          readOnly: field.readOnly,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _stateController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'State / Province'),
          readOnly: field.readOnly,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _zipController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Zip Code'),
          readOnly: field.readOnly,
        ),
        const SizedBox(height: 10),
        _countryFormField!,
      ],
    );
  }
}
