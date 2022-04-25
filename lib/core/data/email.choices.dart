const kEmailTypeChoices = [
  {'name': 'POP3', 'value': 'pop3'},
  {'name': 'IMAP', 'value': 'imap'},
  {'name': 'POP3/IMAP', 'value': 'pop3imap'},
  {'name': '', 'value': ''},
];

const kEmailSecurityChoices = [
  {'name': 'None', 'value': 'none'},
  {'name': 'SSL', 'value': 'ssl'},
  {'name': 'TLS', 'value': 'tls'},
  {'name': '', 'value': ''},
];

const kEmailAuthMethodChoices = [
  {'name': 'None', 'value': 'none'},
  {'name': 'Password', 'value': 'password'},
  {'name': 'MD5 Challenge Response', 'value': 'md5_challenge'},
  {'name': 'Kerberized POP (KPOP)', 'value': 'kpop'},
  {'name': 'Kerberos Version 4', 'value': 'kerberos4'},
  {'name': 'Kerberos Version 5', 'value': 'kerberos5'},
  {'name': 'NTLM', 'value': 'ntlm'},
  {'name': '', 'value': ''},
];
