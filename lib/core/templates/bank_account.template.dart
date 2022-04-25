import '../data/bank_type.choices.dart';

import '../data/address_value.default.dart';
import '../hive/models/field.hive.dart';

List<HiveLisoField> templateBankAccountFields() {
  return [
    HiveLisoField(
      identifier: 'bank_name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Bank Name',
      },
    ),
    HiveLisoField(
      identifier: 'account_name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Account Name',
      },
    ),
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Type',
        'choices': kBankTypeChoices,
      },
    ),
    HiveLisoField(
      identifier: 'routing_number',
      type: LisoFieldType.number.name,
      data: {
        'label': 'Routing Number',
      },
    ),
    HiveLisoField(
      identifier: 'account_number',
      type: LisoFieldType.number.name,
      data: {
        'label': 'Account Number',
      },
    ),
    HiveLisoField(
      identifier: 'swift',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'SWIFT',
      },
    ),
    HiveLisoField(
      identifier: 'iban',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'IBAN',
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
      data: {'value': 'Branch Information'},
    ),
    HiveLisoField(
      identifier: 'branch_phone',
      type: LisoFieldType.phone.name,
      data: {
        'label': 'Phone',
        'hint': '+1-123-456-7890',
      },
    ),
    HiveLisoField(
      identifier: 'branch_address',
      type: LisoFieldType.address.name,
      data: {
        'value': kAddressDefaultValue,
        'label': 'Branch Address',
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
