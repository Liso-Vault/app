import 'package:flutter/material.dart';
import 'package:liso/core/data/countries.choices.dart';
import 'package:liso/core/form_fields/choices.field.dart';
import 'package:liso/core/form_fields/section.field.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/core/utils/console.dart';

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

  // TODO: ADDRESS FIELD JSON TO CLASS
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
    final value = field.data['value'];

    _street1Controller = TextEditingController(text: value['street1']);
    _street2Controller = TextEditingController(text: value['street2']);
    _cityController = TextEditingController(text: value['city']);
    _stateController = TextEditingController(text: value['state']);
    _zipController = TextEditingController(text: value['zip']);

    _countryFormField = ChoicesFormField(
      HiveLisoField(
        type: LisoFieldType.choices.name,
        data: {
          'value': value['country'],
          'label': 'Country',
          'choices': kCountryChoices,
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionFormField(
          HiveLisoField(type: '', data: {'value': field.data['label']}),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _street1Controller,
          keyboardType: TextInputType.streetAddress,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Street 1',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _street2Controller,
          keyboardType: TextInputType.streetAddress,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Street 2'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _cityController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'City'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _stateController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'State / Province',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _zipController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Zip Code'),
        ),
        const SizedBox(height: 10),
        _countryFormField!,
      ],
    );
  }
}
