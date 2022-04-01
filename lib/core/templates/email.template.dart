import '../hive/models/field.hive.dart';

final templateEmailFields = [
  HiveLisoField(
    identifier: 'email',
    reserved: true,
    type: LisoFieldType.email.name,
    data: {
      'value': '',
      'label': 'Email',
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
