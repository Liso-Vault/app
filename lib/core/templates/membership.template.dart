import '../hive/models/field.hive.dart';

List<HiveLisoField> templateMembershipFields() {
  return [
    HiveLisoField(
      identifier: 'group',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Group',
      },
    ),
    HiveLisoField(
      identifier: 'website',
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'Website',
        'hint': 'https://members.com',
      },
    ),
    HiveLisoField(
      identifier: 'telephone',
      type: LisoFieldType.phone.name,
      data: {'value': '', 'label': 'Telephone', 'hint': '+1-123-456-7890'},
    ),
    HiveLisoField(
      identifier: 'member_id',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Username',
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
      identifier: 'member_since',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Member Since',
      },
    ),
    HiveLisoField(
      identifier: 'expiration_date',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Expiration Date',
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
