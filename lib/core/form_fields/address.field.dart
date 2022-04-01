import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/core/form_fields/country.field.dart';
import 'package:liso/core/utils/console.dart';

import '../utils/styles.dart';

// ignore: must_be_immutable
class AddressFormField extends StatelessWidget with ConsoleMixin {
  final HiveLisoField field;
  AddressFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? street1Controller;
  TextEditingController? street2Controller;
  TextEditingController? cityController;
  TextEditingController? stateController;
  TextEditingController? zipController;
  CountryFormField? countryFormField;

  // TODO: ADDRESS FIELD JSON TO CLASS
  Map<String, dynamic> get value {
    return {
      'street1': street1Controller!.text,
      'street2': street2Controller!.text,
      'city': cityController!.text,
      'state': stateController!.text,
      'zip': zipController!.text,
      'country': countryFormField!.dropdown!.value,
    };
  }

  @override
  Widget build(BuildContext context) {
    final value = field.data['value'];

    street1Controller = TextEditingController(text: value['street1']);
    street2Controller = TextEditingController(text: value['street2']);
    cityController = TextEditingController(text: value['city']);
    stateController = TextEditingController(text: value['state']);
    zipController = TextEditingController(text: value['zip']);

    countryFormField = CountryFormField(
      HiveLisoField(
        reserved: true,
        type: LisoFieldType.country.name,
        data: {
          'value': value['country'],
          'label': 'Country',
        },
      ),
    );

    return Column(
      children: [
        TextFormField(
          controller: street1Controller,
          keyboardType: TextInputType.streetAddress,
          textCapitalization: TextCapitalization.words,
          decoration: Styles.inputDecoration.copyWith(labelText: 'Street 1'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: street2Controller,
          keyboardType: TextInputType.streetAddress,
          textCapitalization: TextCapitalization.words,
          decoration: Styles.inputDecoration.copyWith(labelText: 'Street 2'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: cityController,
          textCapitalization: TextCapitalization.words,
          decoration: Styles.inputDecoration.copyWith(labelText: 'City'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: stateController,
          textCapitalization: TextCapitalization.words,
          decoration:
              Styles.inputDecoration.copyWith(labelText: 'State / Province'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: zipController,
          keyboardType: TextInputType.number,
          decoration: Styles.inputDecoration.copyWith(labelText: 'Zip Code'),
        ),
        const SizedBox(height: 10),
        countryFormField!,
      ],
    );
  }
}
