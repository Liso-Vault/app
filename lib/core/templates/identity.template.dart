import '../hive/models/field.hive.dart';

final templateIdentityFields = [
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'First Name',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Middle Name',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Last Name',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.gender.name,
    data: {
      'value': '',
      'label': 'Gender',
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
