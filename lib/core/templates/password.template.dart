import '../hive/models/field.hive.dart';

List<HiveLisoField> templatePasswordFields() {
  return [
    HiveLisoField(
      identifier: 'password',
      type: LisoFieldType.password.name,
      data: {
        'label': 'Password',
      },
    ),
    HiveLisoField(
      identifier: 'website',
      type: LisoFieldType.url.name,
      data: {
        'label': 'Website',
        'hint': 'https://site.com',
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
