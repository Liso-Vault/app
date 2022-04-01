import '../hive/models/field.hive.dart';

final templateIdentityFields = [
  HiveLisoField(
    identifier: 'first_name',
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
    identifier: 'middle_name',
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
    identifier: 'last_name',
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
    identifier: 'gender',
    reserved: true,
    type: LisoFieldType.gender.name,
    data: {
      'value': '',
      'label': 'Gender',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.section.name,
    data: {'value': 'Address'},
  ),
  HiveLisoField(
    identifier: 'address',
    reserved: true,
    type: LisoFieldType.address.name,
    data: {
      'value': {
        'street1': '',
        'street2': '',
        'city': '',
        'state': '',
        'zip': '',
        'country': '',
      },
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
