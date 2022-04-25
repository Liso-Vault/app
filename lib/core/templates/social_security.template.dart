import '../hive/models/field.hive.dart';

List<HiveLisoField> templateSocialSecurityFields() {
  return [
    HiveLisoField(
      identifier: 'name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Name',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Number',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Others'},
    ),
    HiveLisoField(
      identifier: 'note',
      type: LisoFieldType.textArea.name,
      data: {
        'value': '',
        'label': 'Notes',
      },
    ),
  ];
}
