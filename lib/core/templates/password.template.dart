import '../hive/models/field.hive.dart';

final templatePasswordFields = [
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
    type: LisoFieldType.spacer.name,
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.url.name,
    data: {
      'value': '',
      'label': 'Website',
      'hint': 'https://example.com',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.section.name,
    data: {'value': 'Others'},
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
