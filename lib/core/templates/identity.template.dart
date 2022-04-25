import '../data/address_value.default.dart';
import '../data/genders.choices.dart';
import '../hive/models/field.hive.dart';

List<HiveLisoField> templateIdentityFields() {
  return [
    HiveLisoField(
      identifier: 'first_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'First Name',
      },
    ),
    HiveLisoField(
      identifier: 'middle_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Middle Name',
      },
    ),
    HiveLisoField(
      identifier: 'last_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Last Name',
      },
    ),
    HiveLisoField(
      identifier: 'gender',
      type: LisoFieldType.choices.name,
      data: {
        'value': '',
        'label': 'Gender',
        'choices': kGenderChoices,
      },
    ),
    HiveLisoField(
      identifier: 'birth_date',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Birth Date',
      },
    ),
    HiveLisoField(
      identifier: 'occupation',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Occupation',
      },
    ),
    HiveLisoField(
      identifier: 'company',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Company',
      },
    ),
    HiveLisoField(
      identifier: 'department',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Department',
      },
    ),
    HiveLisoField(
      identifier: 'job_title',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Job Title',
      },
    ),
    HiveLisoField(
      identifier: 'phone_number',
      type: LisoFieldType.phone.name,
      data: {'value': '', 'label': 'Phone Number', 'hint': '+1-123-456-7890'},
    ),
    HiveLisoField(
      identifier: 'home_number',
      type: LisoFieldType.phone.name,
      data: {
        'value': '',
        'label': 'Home Phone Number',
        'hint': '+1-123-456-7890'
      },
    ),
    HiveLisoField(
      identifier: 'cell_number',
      type: LisoFieldType.phone.name,
      data: {
        'value': '',
        'label': 'Cell Phone Number',
        'hint': '+1-123-456-7890'
      },
    ),
    HiveLisoField(
      identifier: 'business_number',
      type: LisoFieldType.phone.name,
      data: {
        'value': '',
        'label': 'Business Phone Number',
        'hint': '+1-123-456-7890'
      },
    ),
    HiveLisoField(
      identifier: 'address',
      type: LisoFieldType.address.name,
      data: {
        'value': kAddressDefaultValue,
        'label': 'Address',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Internet Details'},
    ),
    HiveLisoField(
      identifier: 'username',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'email',
      type: LisoFieldType.email.name,
      data: {
        'value': '',
        'label': 'Email',
      },
    ),
    HiveLisoField(
      identifier: 'website',
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'Website',
        'hint': 'https://website.com',
      },
    ),
    HiveLisoField(
      identifier: 'twitter',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Twitter',
      },
    ),
    HiveLisoField(
      identifier: 'facebook',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Facebook',
      },
    ),
    HiveLisoField(
      identifier: 'instagram',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Instagram',
      },
    ),
    HiveLisoField(
      identifier: 'tiktok',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'TikTok',
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
