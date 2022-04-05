import '../hive/models/field.hive.dart';

List<HiveLisoField> templatePasswordFields() {
  return [
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
      type: LisoFieldType.spacer.name,
    ),
    HiveLisoField(
      identifier: 'website',
      reserved: true,
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'Website',
        'hint': 'https://example.com',
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
