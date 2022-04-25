import '../data/address_value.default.dart';
import '../data/genders.choices.dart';
import '../hive/models/field.hive.dart';

List<HiveLisoField> templateDriversLicenseFields() {
  return [
    HiveLisoField(
      identifier: 'full_name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Full Name',
      },
    ),
    HiveLisoField(
      identifier: 'birthdate',
      type: LisoFieldType.date.name,
      data: {
        'label': 'Birth Date',
      },
    ),
    HiveLisoField(
      identifier: 'gender',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Gender',
        'choices': kGenderChoices,
      },
    ),
    HiveLisoField(
      identifier: 'height',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Height',
      },
    ),
    HiveLisoField(
      identifier: 'number',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Number',
      },
    ),
    HiveLisoField(
      identifier: 'license_class',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'License Class',
      },
    ),
    HiveLisoField(
      identifier: 'conditions',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Conditions',
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
      identifier: 'address',
      type: LisoFieldType.address.name,
      data: {
        'value': kAddressDefaultValue,
        'label': 'Address',
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
