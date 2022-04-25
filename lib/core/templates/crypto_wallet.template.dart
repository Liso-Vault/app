import '../hive/models/field.hive.dart';

List<HiveLisoField> templateCryptoWalletFields() {
  return [
    HiveLisoField(
      identifier: 'seed',
      type: LisoFieldType.mnemonicSeed.name,
      data: {
        'label': 'Seed Phrase',
      },
    ),
    HiveLisoField(
      identifier: 'password',
      type: LisoFieldType.password.name,
      data: {
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
