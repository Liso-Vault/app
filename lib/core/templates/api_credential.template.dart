import 'package:liso/core/data/api_credential.choices.dart';

import '../hive/models/field.hive.dart';

List<HiveLisoField> templateAPICredentialFields() {
  return [
    HiveLisoField(
      identifier: 'username',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'credential',
      type: LisoFieldType.password.name,
      data: {
        'value': '',
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.choices.name,
      data: {
        'value': '',
        'label': 'Type',
        'choices': kAPICredentialTypeChoices,
      },
    ),
    HiveLisoField(
      identifier: 'file_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'File Name',
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
      identifier: 'expiration_date',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Expiration Date',
      },
    ),
    HiveLisoField(
      identifier: 'host_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
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
      data: {'value': '', 'label': 'Notes'},
    ),
  ];
}
