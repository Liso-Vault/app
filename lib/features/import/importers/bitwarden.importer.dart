import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/ui_utils.dart';
import '../import_screen.controller.dart';

const validColumns = [
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
    final sourceFormat = ImportScreenController.to.sourceFormat.value;
    const csvConverter = CsvToListConverter();
    final values = csvConverter.convert(csv, eol: '\n');
    final columns = values.first.sublist(0, validColumns.length);

    if (!listEquals(columns, validColumns)) {
      await UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid ${sourceFormat.title} exported file',
      );

      return false;
    }

    return true;
  }
}
