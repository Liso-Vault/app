import '../hive/models/field.hive.dart';

final templateCashCardFields = [
  HiveLisoField(
    identifier: 'pin',
    reserved: true,
    type: LisoFieldType.pin.name,
    data: {
      'value': '',
      'label': 'PIN Code',
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
