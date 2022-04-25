import '../data/email.choices.dart';

import '../hive/models/field.hive.dart';

List<HiveLisoField> templateEmailFields() {
  return [
    HiveLisoField(
      identifier: 'type',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Type',
        'choices': kEmailTypeChoices,
      },
    ),
    HiveLisoField(
      identifier: 'username',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'server',
      type: LisoFieldType.url.name,
      data: {
        'label': 'Server',
        'hint': 'https://server.com',
      },
    ),
    HiveLisoField(
      identifier: 'port_number',
      type: LisoFieldType.number.name,
      data: {
        'label': 'Port Number',
        'hint': '8080',
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
      identifier: 'security',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Security',
        'choices': kEmailSecurityChoices,
      },
    ),
    HiveLisoField(
      identifier: 'auth_method',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Auth Method',
        'choices': kEmailAuthMethodChoices,
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'SMTP'},
    ),
    HiveLisoField(
      identifier: 'smtp_server',
      type: LisoFieldType.url.name,
      data: {
        'label': 'SMTP Server',
        'hint': 'https://server.com',
      },
    ),
    HiveLisoField(
      identifier: 'smtp_port_number',
      type: LisoFieldType.number.name,
      data: {
        'label': 'Port Number',
        'hint': '8080',
      },
    ),
    HiveLisoField(
      identifier: 'smtp_username',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Username',
      },
    ),
    HiveLisoField(
      identifier: 'smtp_password',
      type: LisoFieldType.password.name,
      data: {
        'label': 'Password',
      },
    ),
    HiveLisoField(
      identifier: 'smtp_security',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Security',
        'choices': kEmailSecurityChoices,
      },
    ),
    HiveLisoField(
      identifier: 'smtp_auth_method',
      type: LisoFieldType.choices.name,
      data: {
        'label': 'Auth Method',
        'choices': kEmailAuthMethodChoices,
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Contact Information'},
    ),
    HiveLisoField(
      identifier: 'provider',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Provider',
      },
    ),
    HiveLisoField(
      identifier: 'provider_website',
      type: LisoFieldType.url.name,
      data: {
        'label': 'Provider Website',
        'hint': 'https://provider.com',
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
