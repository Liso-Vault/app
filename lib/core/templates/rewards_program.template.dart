import '../hive/models/field.hive.dart';

List<HiveLisoField> templateRewardsProgramFields() {
  return [
    HiveLisoField(
      identifier: 'company_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Company Name',
      },
    ),
    HiveLisoField(
      identifier: 'member_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Member Name',
      },
    ),
    HiveLisoField(
      identifier: 'member_id',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Member ID',
      },
    ),
    HiveLisoField(
      identifier: 'pin',
      type: LisoFieldType.pin.name,
      data: {
        'value': '',
        'label': 'PIN',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'More Information'},
    ),
    HiveLisoField(
      identifier: 'member_since',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Member Since',
      },
    ),
    HiveLisoField(
      identifier: 'customer_service_phone',
      type: LisoFieldType.phone.name,
      data: {
        'value': '',
        'label': 'Customer Service Phone',
        'hint': '+1-123-456-7890'
      },
    ),
    HiveLisoField(
      identifier: 'website',
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'Wesbite',
        'hint': 'https://rewards.com',
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
