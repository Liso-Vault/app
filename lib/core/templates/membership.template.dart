import '../hive/models/field.hive.dart';

final templateMembershipFields = [
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Title',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.divider.name,
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.textArea.name,
    data: {
      'value': '',
      'label': 'Notes',
    },
  ),
];
