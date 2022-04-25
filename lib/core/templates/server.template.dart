import '../hive/models/field.hive.dart';

List<HiveLisoField> templateServerFields() {
  return [
    HiveLisoField(
      identifier: 'url',
      type: LisoFieldType.url.name,
      data: {
        'label': 'URL',
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
      type: LisoFieldType.section.name,
      data: {'value': 'Admin'},
    ),
    HiveLisoField(
      identifier: 'admin_url',
      type: LisoFieldType.url.name,
      data: {
        'label': 'Admin Console URL',
        'hint': 'https://console.com',
      },
    ),
    HiveLisoField(
      identifier: 'admin_username',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Admin Username',
      },
    ),
    HiveLisoField(
      identifier: 'admin_password',
      type: LisoFieldType.password.name,
      data: {
        'label': 'Admin Password',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Hosting Provider'},
    ),
    HiveLisoField(
      identifier: 'hosting_name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Name',
      },
    ),
    HiveLisoField(
      identifier: 'hosting_website',
      type: LisoFieldType.url.name,
      data: {
        'label': 'Website',
        'hint': 'https://hosting.com',
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
