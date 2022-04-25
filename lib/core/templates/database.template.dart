import '../data/database.choices.dart';

import '../hive/models/field.hive.dart';

List<HiveLisoField> templateDatabaseFields() {
  return [
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Type',
        'choices': kDatabaseTypeChoices,
      },
    ),
    HiveLisoField(
      identifier: 'server',
      type: LisoFieldType.url.name,
      data: {
        'label': 'Server',
        'hint': 'https://server.com',
      },
    ),
    HiveLisoField(
      identifier: 'port',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Port',
        'hint': '8080',
      },
    ),
    HiveLisoField(
      identifier: 'database',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Database',
      },
    ),
    HiveLisoField(
      identifier: 'username',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'password',
      type: LisoFieldType.password.name,
      data: {
        'label': 'Password',
      },
    ),
    HiveLisoField(
      identifier: 'sid',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'SID',
      },
    ),
    HiveLisoField(
      identifier: 'alias',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Alias',
      },
    ),
    HiveLisoField(
      identifier: 'connection_options',
      type: LisoFieldType.textField.name,
      data: {
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
        'label': 'Notes',
      },
    ),
  ];
}
