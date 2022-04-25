import '../hive/models/field.hive.dart';

List<HiveLisoField> templateCryptoWalletFields() {
  return [
    HiveLisoField(
      identifier: 'seed',
      type: LisoFieldType.mnemonicSeed.name,
      data: {
        'value': '',
        'label': 'Seed Phrase',
      },
    ),
    HiveLisoField(
      identifier: 'password',
      type: LisoFieldType.password.name,
      data: {
        'value': '',
        'label': 'Password',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Wallet'},
    ),
    HiveLisoField(
      identifier: 'address',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
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
        'value': '',
        'label': 'Notes',
      },
    ),
  ];
}
