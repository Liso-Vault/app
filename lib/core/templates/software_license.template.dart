import '../hive/models/field.hive.dart';

List<HiveLisoField> templateSoftwareLicenseFields() {
  return [
    HiveLisoField(
      identifier: 'version',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Version',
      },
    ),
    HiveLisoField(
      identifier: 'license_key',
      type: LisoFieldType.textField.name,
      data: {
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
        'label': 'Licensed To',
      },
    ),
    HiveLisoField(
      identifier: 'registered_email',
      type: LisoFieldType.email.name,
      data: {
        'label': 'Registered Email',
      },
    ),
    HiveLisoField(
      identifier: 'company',
      type: LisoFieldType.textField.name,
      data: {
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
        'label': 'Download Page',
        'hint': 'https://page.com/downloads',
      },
    ),
    HiveLisoField(
      identifier: 'publisher',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Publisher',
      },
    ),
    HiveLisoField(
      identifier: 'website',
      type: LisoFieldType.url.name,
      data: {
        'label': 'Website',
        'hint': 'https://software.com',
      },
    ),
    HiveLisoField(
      identifier: 'retail_price',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Retail Price',
      },
    ),
    HiveLisoField(
      identifier: 'support_email',
      type: LisoFieldType.email.name,
      data: {
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
        'label': 'Purchase Date',
      },
    ),
    HiveLisoField(
      identifier: 'order_number',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Order Number',
      },
    ),
    HiveLisoField(
      identifier: 'order_total',
      type: LisoFieldType.textField.name,
      data: {
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
        'label': 'Notes',
      },
    ),
  ];
}
