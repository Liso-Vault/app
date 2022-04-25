import '../data/database.choices.dart';

import '../hive/models/field.hive.dart';

List<HiveLisoField> templateDatabaseFields() {
  return [
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.choices.name,
      data: {
        'value': '',
        'label': 'Type',
        'choices': kDatabaseTypeChoices,
      },
    ),
    HiveLisoField(
      identifier: 'server',
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'Server',
        'hint': 'https://server.com',
      },
    ),
    HiveLisoField(
      identifier: 'port',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Port',
        'hint': '8080',
      },
    ),
    HiveLisoField(
      identifier: 'database',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Database',
      },
    ),
    HiveLisoField(
      identifier: 'username',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'password',
      type: LisoFieldType.password.name,
      data: {
        'value': '',
        'label': 'Password',
      },
    ),
    HiveLisoField(
      identifier: 'sid',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'SID',
      },
    ),
    HiveLisoField(
      identifier: 'alias',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Alias',
      },
    ),
    HiveLisoField(
      identifier: 'connection_options',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Connection Options',
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
