import '../hive/models/field.hive.dart';

List<HiveLisoField> templateMembershipFields() {
  return [
    HiveLisoField(
      identifier: 'group',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Group',
      },
    ),
    HiveLisoField(
      identifier: 'website',
      type: LisoFieldType.url.name,
      data: {
        'label': 'Website',
        'hint': 'https://members.com',
      },
    ),
    HiveLisoField(
      identifier: 'telephone',
      type: LisoFieldType.phone.name,
      data: {'label': 'Telephone', 'hint': '+1-123-456-7890'},
    ),
    HiveLisoField(
      identifier: 'member_id',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'member_name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Member Name',
      },
    ),
    HiveLisoField(
      identifier: 'member_since',
      type: LisoFieldType.date.name,
      data: {
        'label': 'Member Since',
      },
    ),
    HiveLisoField(
      identifier: 'expiration_date',
      type: LisoFieldType.date.name,
      data: {
        'label': 'Expiration Date',
      },
    ),
    HiveLisoField(
      identifier: 'pin',
      type: LisoFieldType.pin.name,
      data: {
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
        'label': 'Notes',
      },
    ),
  ];
}
