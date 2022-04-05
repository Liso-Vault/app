import '../hive/models/field.hive.dart';

List<HiveLisoField> templateDatabaseFields() {
  return [
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
