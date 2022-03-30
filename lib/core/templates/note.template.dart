import '../hive/models/field.hive.dart';

final templateNoteFields = [
  HiveLisoField(
    type: LisoFieldType.richText.name,
    reserved: true,
    data: {
      'value': '',
      'label': 'Note',
    },
  ),
];
