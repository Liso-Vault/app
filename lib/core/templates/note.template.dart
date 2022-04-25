import '../hive/models/field.hive.dart';

List<HiveLisoField> templateNoteFields() {
  return [
    HiveLisoField(
      identifier: 'note',
      type: LisoFieldType.richText.name,
      data: {
        'value': '',
        'label': 'Note',
      },
    ),
  ];
}
