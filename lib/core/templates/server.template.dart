import '../hive/models/field.hive.dart';

List<HiveLisoField> templateServerFields() {
  return [
    HiveLisoField(
      identifier: 'url',
      reserved: true,
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'URL',
      },
    ),
    HiveLisoField(
      reserved: true,
      type: LisoFieldType.spacer.name,
    ),
    HiveLisoField(
      identifier: 'username',
      reserved: true,
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Username',
      },
    ),
    HiveLisoField(
      reserved: true,
      type: LisoFieldType.spacer.name,
    ),
    HiveLisoField(
      identifier: 'password',
      reserved: true,
      type: LisoFieldType.password.name,
      data: {
        'value': '',
        'label': 'Password',
      },
    ),
    HiveLisoField(
      reserved: true,
      type: LisoFieldType.section.name,
      data: {'value': 'Admin'},
    ),
    HiveLisoField(
      identifier: 'admin_url',
      reserved: true,
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'Admin Console URL',
      },
    ),
    HiveLisoField(
      reserved: true,
      type: LisoFieldType.spacer.name,
    ),
    HiveLisoField(
      identifier: 'admin_username',
      reserved: true,
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Admin Username',
      },
    ),
    HiveLisoField(
      reserved: true,
      type: LisoFieldType.spacer.name,
    ),
    HiveLisoField(
      identifier: 'admin_password',
      reserved: true,
      type: LisoFieldType.password.name,
      data: {
        'value': '',
        'label': 'Admin Password',
      },
    ),
    HiveLisoField(
      reserved: true,
      type: LisoFieldType.section.name,
      data: {'value': 'Hosting Provider'},
    ),
    HiveLisoField(
      identifier: 'hosting_provider',
      reserved: true,
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Name',
      },
    ),
    HiveLisoField(
      reserved: true,
      type: LisoFieldType.section.name,
      data: {'value': 'Others'},
    ),
    HiveLisoField(
      identifier: 'note',
      reserved: true,
      type: LisoFieldType.textArea.name,
      data: {
        'value': '',
        'label': 'Notes',
      },
    ),
  ];
}
