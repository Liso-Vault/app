import '../data/wireless_security.choices.dart';
import '../hive/models/field.hive.dart';

List<HiveLisoField> templateWirelessRouterFields() {
  return [
    HiveLisoField(
      identifier: 'base_station_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Base Station Name',
      },
    ),
    HiveLisoField(
      identifier: 'base_station_password',
      type: LisoFieldType.password.name,
      data: {
        'value': '',
        'label': 'Base Station Password',
      },
    ),
    HiveLisoField(
      identifier: 'server',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Server / IP Address',
      },
    ),
    HiveLisoField(
      identifier: 'airport_id',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Airport ID',
      },
    ),
    HiveLisoField(
      identifier: 'network_name',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Network Name',
      },
    ),
    HiveLisoField(
      identifier: 'wireless_security',
      type: LisoFieldType.choices.name,
      data: {
        'value': '',
        'label': 'Wireless Security',
        'choices': kWirelessSecurityChoices,
      },
    ),
    HiveLisoField(
      identifier: 'wireless_network_password',
      type: LisoFieldType.password.name,
      data: {
        'value': '',
        'label': 'Wireless Network Password',
      },
    ),
    HiveLisoField(
      identifier: 'wireless_storage_password',
      type: LisoFieldType.password.name,
      data: {
        'value': '',
        'label': 'Wireless Storage Password',
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
