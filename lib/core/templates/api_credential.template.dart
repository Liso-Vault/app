import '../data/api_credential.choices.dart';

import '../hive/models/field.hive.dart';

List<HiveLisoField> templateAPICredentialFields() {
  return [
    HiveLisoField(
      identifier: 'username',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'credential',
      type: LisoFieldType.password.name,
      data: {
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Type',
        'choices': kAPICredentialTypeChoices,
      },
    ),
    HiveLisoField(
      identifier: 'file_name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'File Name',
      },
    ),
    HiveLisoField(
      identifier: 'valid_from',
      type: LisoFieldType.date.name,
      data: {
        'label': 'Valid From',
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
      identifier: 'host_name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Host Name',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Others'},
    ),
    HiveLisoField(
      identifier: 'note',
      type: LisoFieldType.textArea.name,
      data: {'label': 'Notes'},
    ),
  ];
}
