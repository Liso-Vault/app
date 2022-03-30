import '../hive/models/field.hive.dart';

final templateCryptoWalletFields = [
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.textField.name,
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
    reserved: true,
    type: LisoFieldType.textField.name,
    data: {
      'value': '',
      'label': 'Address',
    },
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.divider.name,
  ),
  HiveLisoField(
    reserved: true,
    type: LisoFieldType.textArea.name,
    data: {
      'value': '',
      'label': 'Notes',
    },
  ),
];
