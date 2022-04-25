import '../data/cash_card.choices.dart';

import '../hive/models/field.hive.dart';

List<HiveLisoField> templateCashCardFields() {
  return [
    HiveLisoField(
      identifier: 'holder_name',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Cardholder Name',
      },
    ),
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Type',
        'choices': kCashCardTypeChoices,
      },
    ),
    HiveLisoField(
      identifier: 'card_number',
      type: LisoFieldType.number.name,
      data: {
        'label': 'Number',
      },
    ),
    HiveLisoField(
      identifier: 'verification_number',
      type: LisoFieldType.pin.name,
      data: {
        'label': 'Verification Number',
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
      identifier: 'valid_from',
      type: LisoFieldType.date.name,
      data: {
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
        'label': 'Issuing Bank',
      },
    ),
    HiveLisoField(
      identifier: 'local_phone',
      type: LisoFieldType.phone.name,
      data: {'label': 'Phone (Local)', 'hint': '+1-123-456-7890'},
    ),
    HiveLisoField(
      identifier: 'toll_free_phone',
      type: LisoFieldType.phone.name,
      data: {'label': 'Phone (Toll Free)', 'hint': '+1-123-456-7890'},
    ),
    HiveLisoField(
      identifier: 'intl_phone',
      type: LisoFieldType.phone.name,
      data: {'label': 'Phone (International)', 'hint': '+1-123-456-7890'},
    ),
    HiveLisoField(
      identifier: 'website',
      type: LisoFieldType.url.name,
      data: {
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
        'label': 'PIN',
      },
    ),
    HiveLisoField(
      identifier: 'credit_limit',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Credit Limit',
      },
    ),
    HiveLisoField(
      identifier: 'withdrawal_limit',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Withdrawal Limit',
      },
    ),
    HiveLisoField(
      identifier: 'interest_rate',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Interest Rate',
      },
    ),
    HiveLisoField(
      identifier: 'issue_number',
      type: LisoFieldType.number.name,
      data: {
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
        'label': 'Notes',
      },
    ),
  ];
}
