import '../hive/models/field.hive.dart';

final templateServerFields = [
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.url.name,
    data: {
      'value': '',
      'label': 'URL',
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
      'label': 'Username',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.password.name,
    data: {
      'value': '',
      'label': 'Password',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.section.name,
    data: {'value': 'Admin'},
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.url.name,
    data: {
      'value': '',
      'label': 'Admin Console URL',
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
      'label': 'Admin Username',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.password.name,
    data: {
      'value': '',
      'label': 'Admin Password',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.section.name,
    data: {'value': 'Hosting Provider'},
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Name',
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
