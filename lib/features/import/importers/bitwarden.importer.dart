import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/ui_utils.dart';

const kBitwardenCSVColumns = [
  'folder',
  'favorite',
  'type',
  'name',
  'notes',
  'fields',
  'reprompt',
  'login_uri',
  'login_username',
  'login_password',
  'login_totp'
];

class BitwardenImporter {
  static final console = Console(name: 'BitwardenImporter');

  static Future<bool> importCSV(String csv) async {
    const csvConverter = CsvToListConverter();
    final values = csvConverter.convert(csv, eol: '\n');
    final columns = values.first.sublist(0, kBitwardenCSVColumns.length);

    if (!listEquals(columns, kBitwardenCSVColumns)) {
      await UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid LastPass CSV exported file',
      );

      return false;
    }

    return true;
  }
}
