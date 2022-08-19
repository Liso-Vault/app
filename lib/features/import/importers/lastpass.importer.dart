import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/ui_utils.dart';

const kLastPassCSVColumns = [
  'url',
  'username',
  'password',
  'totp',
  'extra',
  'name',
  'grouping',
  'fav'
];

class LastPassImporter {
  static final console = Console(name: 'LastPassImporter');

  static Future<bool> importCSV(String csv) async {
    const csvConverter = CsvToListConverter();
    final values = csvConverter.convert(csv, eol: '\n');
    final columns = values.first.sublist(0, kLastPassCSVColumns.length);

    if (!listEquals(columns, kLastPassCSVColumns)) {
      await UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid LastPass CSV exported file',
      );

      return false;
    }

    // print csv values
    for (var row in values) {
      // final grouping = row[6];
      // final extra = row[4];
      // console.info('extra: ${row[4].split('\n')}');

      console.warning('url: ${row[0]}');
      console.warning('username: ${row[1]}');
      console.warning('password: ${row[2]}');
      console.warning('totp: ${row[3]}');
      console.warning('name: ${row[5]}');
      console.warning('grouping: ${row[6]}');
      console.warning('fav: ${row[7]}');
      console.debug('extra: ${row[4].split('\n')}');

      console.info('############');
    }

    // final metadata = await HiveMetadata.get();

    // final items = values.map(
    //   (e) {
    //     return HiveLisoItem(
    //       identifier: const Uuid().v4(),
    //       groupId: groupId,
    //       category: category,
    //       title: e[5],
    //       fields: fields,
    //       favorite: e[7] == 1,
    //       // TODO: obtain iconUrl based on url
    //       // iconUrl: iconUrl.value,
    //       uris: [e[0]],
    //       appIds: appIds,
    //       metadata: metadata,
    //       tags: [
    //         ImportScreenController.to.sourceFormat.value.name.toLowerCase()
    //       ],
    //     );
    //   },
    // ).toList();

    // console.info('items: ${items.length}');

    return true;
  }
}
