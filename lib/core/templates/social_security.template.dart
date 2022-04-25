import '../hive/models/field.hive.dart';

List<HiveLisoField> templateSocialSecurityFields() {
  return [
    HiveLisoField(
      identifier: 'name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Name',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.textField.name,
      data: {
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
        'label': 'Notes',
      },
    ),
  ];
}
