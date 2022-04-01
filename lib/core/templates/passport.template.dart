import '../hive/models/field.hive.dart';

final templatePassportFields = [
  HiveLisoField(
    identifier: 'type',
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Type',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    identifier: 'issuing_country',
    reserved: true,
    type: LisoFieldType.country.name,
    data: {
      'value': '',
      'label': 'Issuing Country',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    identifier: 'number',
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Number',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    identifier: 'full_name',
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Full Name',
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
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    identifier: 'nationality',
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Nationality',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    identifier: 'issuing_authority',
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Issuing Authority',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    identifier: 'date_of_birth',
    reserved: true,
    type: LisoFieldType.date.name,
    data: {
      'value': '',
      'label': 'Date of Birth',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    identifier: 'issued_on',
    reserved: true,
    type: LisoFieldType.date.name,
    data: {
      'value': '',
      'label': 'Issued On',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    identifier: 'expiry_date',
    reserved: true,
    type: LisoFieldType.date.name,
    data: {
      'value': '',
      'label': 'Expiry Date',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.divider.name,
  ),
  HiveLisoField(
    identifier: 'note',
    type: LisoFieldType.textArea.name,
    reserved: true,
    data: {
      'value': '',
      'label': 'Note',
    },
  ),
];
