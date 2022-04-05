import '../hive/models/field.hive.dart';

List<HiveLisoField> templateSocialSecurityFields() {
  return [
    HiveLisoField(
      identifier: 'name',
      reserved: true,
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Name',
      },
    ),
    HiveLisoField(
      identifier: 'number',
      reserved: true,
      type: LisoFieldType.spacer.name,
    ),
    HiveLisoField(
      type: LisoFieldType.textField.name,
      reserved: true,
      data: {
        'value': '',
        'label': 'Number',
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
}
