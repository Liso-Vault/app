import '../hive/models/field.hive.dart';

List<HiveLisoField> templateCryptoWalletFields() {
  return [
    HiveLisoField(
      identifier: 'seed',
      reserved: true,
      type: LisoFieldType.mnemonicSeed.name,
      data: {
        'value': '',
        'label': 'Seed Phrase',
      },
    ),
    HiveLisoField(
      reserved: true,
      type: LisoFieldType.spacer.name,
    ),
    HiveLisoField(
      identifier: 'address',
      reserved: true,
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Address',
      },
    ),
    HiveLisoField(
      reserved: true,
      type: LisoFieldType.section.name,
      data: {'value': 'Others'},
    ),
    HiveLisoField(
      identifier: 'note',
      reserved: true,
      type: LisoFieldType.textArea.name,
      data: {
        'value': '',
        'label': 'Notes',
      },
    ),
  ];
}
