import '../data/cash_card.choices.dart';

import '../hive/models/field.hive.dart';

List<HiveLisoField> templateCashCardFields() {
  return [
    HiveLisoField(
      identifier: 'holder_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Cardholder Name',
      },
    ),
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.choices.name,
      data: {
        'value': '',
        'label': 'Type',
        'choices': kCashCardTypeChoices,
      },
    ),
    HiveLisoField(
      identifier: 'card_number',
      type: LisoFieldType.number.name,
      data: {
        'value': '',
        'label': 'Number',
      },
    ),
    HiveLisoField(
      identifier: 'verification_number',
      type: LisoFieldType.pin.name,
      data: {
        'value': '',
        'label': 'Verification Number',
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
      identifier: 'valid_from',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Valid From',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Contact Information'},
    ),
    HiveLisoField(
      identifier: 'issuing_bank',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Issuing Bank',
      },
    ),
    HiveLisoField(
      identifier: 'local_phone',
      type: LisoFieldType.phone.name,
      data: {'value': '', 'label': 'Phone (Local)', 'hint': '+1-123-456-7890'},
    ),
    HiveLisoField(
      identifier: 'toll_free_phone',
      type: LisoFieldType.phone.name,
      data: {
        'value': '',
        'label': 'Phone (Toll Free)',
        'hint': '+1-123-456-7890'
      },
    ),
    HiveLisoField(
      identifier: 'intl_phone',
      type: LisoFieldType.phone.name,
      data: {
        'value': '',
        'label': 'Phone (International)',
        'hint': '+1-123-456-7890'
      },
    ),
    HiveLisoField(
      identifier: 'website',
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'Website',
        'hint': 'https://bank.com',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Additional Details'},
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
      identifier: 'credit_limit',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Credit Limit',
      },
    ),
    HiveLisoField(
      identifier: 'withdrawal_limit',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Withdrawal Limit',
      },
    ),
    HiveLisoField(
      identifier: 'interest_rate',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Interest Rate',
      },
    ),
    HiveLisoField(
      identifier: 'issue_number',
      type: LisoFieldType.number.name,
      data: {
        'value': '',
        'label': 'Issue Number',
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
