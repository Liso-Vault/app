import 'package:liso/core/data/countries.choices.dart';

import '../data/genders.dart';
import '../hive/models/field.hive.dart';

List<HiveLisoField> templatePassportFields() {
  return [
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Type',
      },
    ),
    HiveLisoField(
      identifier: 'issuing_country',
      type: LisoFieldType.choices.name,
      data: {
        'value': '',
        'label': 'Issuing Country',
        'choices': kCountryChoices,
      },
    ),
    HiveLisoField(
      identifier: 'number',
      type: LisoFieldType.passport.name,
      data: {
        'value': '',
        'label': 'Number',
      },
    ),
    HiveLisoField(
      identifier: 'full_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Full Name',
      },
    ),
    HiveLisoField(
      identifier: 'gender',
      type: LisoFieldType.choices.name,
      data: {
        'value': '',
        'label': 'Gender',
        'choices': kGenderChoices,
      },
    ),
    HiveLisoField(
      identifier: 'nationality',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Nationality',
      },
    ),
    HiveLisoField(
      identifier: 'issuing_authority',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Issuing Authority',
      },
    ),
    HiveLisoField(
      identifier: 'date_of_birth',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Date of Birth',
      },
    ),
    HiveLisoField(
      identifier: 'issued_on',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Issued On',
      },
    ),
    HiveLisoField(
      identifier: 'expiration_date',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Expiration Date',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Others'},
    ),
    HiveLisoField(
      identifier: 'note',
      type: LisoFieldType.textArea.name,
      data: {
        'value': '',
        'label': 'Note',
      },
    ),
  ];
}
