import '../hive/models/field.hive.dart';

List<HiveLisoField> templateSoftwareLicenseFields() {
  return [
    HiveLisoField(
      identifier: 'version',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Version',
      },
    ),
    HiveLisoField(
      identifier: 'license_key',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'License Key',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Customer'},
    ),
    HiveLisoField(
      identifier: 'licensed_to',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Licensed To',
      },
    ),
    HiveLisoField(
      identifier: 'registered_email',
      type: LisoFieldType.email.name,
      data: {
        'value': '',
        'label': 'Registered Email',
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
      type: LisoFieldType.section.name,
      data: {'value': 'Publisher'},
    ),
    HiveLisoField(
      identifier: 'download_page',
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'Download Page',
        'hint': 'https://page.com/downloads',
      },
    ),
    HiveLisoField(
      identifier: 'publisher',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Publisher',
      },
    ),
    HiveLisoField(
      identifier: 'website',
      type: LisoFieldType.url.name,
      data: {
        'value': '',
        'label': 'Website',
        'hint': 'https://software.com',
      },
    ),
    HiveLisoField(
      identifier: 'retail_price',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Retail Price',
      },
    ),
    HiveLisoField(
      identifier: 'support_email',
      type: LisoFieldType.email.name,
      data: {
        'value': '',
        'label': 'Support Email',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Order'},
    ),
    HiveLisoField(
      identifier: 'purchase_date',
      type: LisoFieldType.date.name,
      data: {
        'value': '',
        'label': 'Purchase Date',
      },
    ),
    HiveLisoField(
      identifier: 'order_number',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Order Number',
      },
    ),
    HiveLisoField(
      identifier: 'order_total',
      type: LisoFieldType.textField.name,
      data: {
        'value': '',
        'label': 'Order Total',
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
