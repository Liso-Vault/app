import 'package:liso/core/data/countries.choices.dart';

import '../hive/models/field.hive.dart';

List<HiveLisoField> templateOutdoorLicenseFields() {
  return [
    HiveLisoField(
      identifier: 'full_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Full Name',
      },
    ),
    HiveLisoField(
      identifier: 'valid_from',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Valid From',
      },
    ),
    HiveLisoField(
      identifier: 'expires',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Expires',
      },
    ),
    HiveLisoField(
      identifier: 'approved_wildlife',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Approved Wildlife',
      },
    ),
    HiveLisoField(
      identifier: 'maximum_quota',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Maximum Quota',
      },
    ),
    HiveLisoField(
      identifier: 'state',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'State',
      },
    ),
    HiveLisoField(
      identifier: 'country',
      type: LisoFieldType.choices.name,
      data: {
        'value': '',
        'label': 'Country',
        'choices': kCountryChoices,
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
        'label': 'Notes',
      },
    ),
  ];
}
