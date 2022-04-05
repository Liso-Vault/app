import '../hive/models/field.hive.dart';

List<HiveLisoField> templateNoteFields() {
  return [
    HiveLisoField(
      identifier: 'note',
      type: LisoFieldType.richText.name,
      reserved: true,
      data: {
        'value': '',
        'label': 'Note',
      },
    ),
  ];
}
