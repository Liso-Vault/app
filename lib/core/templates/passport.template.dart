import '../data/countries.choices.dart';

import '../data/genders.choices.dart';
import '../hive/models/field.hive.dart';

List<HiveLisoField> templatePassportFields() {
  return [
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Type',
      },
    ),
    HiveLisoField(
      identifier: 'issuing_country',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Issuing Country',
        'choices': kCountryChoices,
      },
    ),
    HiveLisoField(
      identifier: 'number',
      type: LisoFieldType.passport.name,
      data: {
        'label': 'Number',
      },
    ),
    HiveLisoField(
      identifier: 'full_name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Full Name',
      },
    ),
    HiveLisoField(
      identifier: 'gender',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Gender',
        'choices': kGenderChoices,
      },
    ),
    HiveLisoField(
      identifier: 'nationality',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Nationality',
      },
    ),
    HiveLisoField(
      identifier: 'issuing_authority',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Issuing Authority',
      },
    ),
    HiveLisoField(
      identifier: 'date_of_birth',
      type: LisoFieldType.date.name,
      data: {
        'label': 'Date of Birth',
      },
    ),
    HiveLisoField(
      identifier: 'issued_on',
      type: LisoFieldType.date.name,
      data: {
        'label': 'Issued On',
      },
    ),
    HiveLisoField(
      identifier: 'expiration_date',
      type: LisoFieldType.date.name,
      data: {
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
        'label': 'Note',
      },
    ),
  ];
}
