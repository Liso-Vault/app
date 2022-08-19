import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:uuid/uuid.dart';

import '../../../core/hive/models/item.hive.dart';
import '../../../core/hive/models/metadata/metadata.hive.dart';
import '../../../core/utils/ui_utils.dart';
import '../../categories/categories.controller.dart';
import '../../groups/groups.controller.dart';
import '../import_screen.controller.dart';

const kChromeCSVColumns = [
  'name',
  'url',
  'username',
  'password',
];

class ChromeImporter {
  static final console = Console(name: 'ChromeImporter');

  static Future<bool> importCSV(String csv) async {
    const csvConverter = CsvToListConverter();
    final values = csvConverter.convert(csv);
    final columns = values.first.sublist(0, kChromeCSVColumns.length);

    if (!listEquals(columns, kChromeCSVColumns)) {
      await UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid LastPass CSV exported file',
      );

      return false;
    }

    final metadata = await HiveMetadata.get();
    final sourceFormat = ImportScreenController.to.sourceFormat.value;
    String groupId = ImportScreenController.to.destinationGroupId.value;

    final items = values.map(
      (row) {
        // group
        if (groupId == 'smart-vault-destination') {
          // use personal
          groupId = GroupsController.to.combined.first.id;
        }

        // category
        final category = CategoriesController.to.combined.firstWhere(
          (e) => e.id == LisoItemCategory.login.name,
        );

        final name = row[0];
        final url = row[1];
        final username = row[2];
        final password = row[3];

        // print csv values
        console.warning('name: $name');
        console.warning('url: $url');
        console.warning('username: $username');
        console.warning('password: $password');
        console.info('############');

        final fields = category.fields.map((e) {
          if (e.identifier == 'website') {
            e.data.value = url;
          } else if (e.identifier == 'username') {
            e.data.value = username;
          } else if (e.identifier == 'password') {
            e.data.value = password;
          } else if (e.identifier == 'note') {
            e.data.value = 'Imported via ${sourceFormat.title}';
          }

          return e;
        }).toList();

        return HiveLisoItem(
          identifier: const Uuid().v4(),
          groupId: groupId,
          category: category.id,
          title: name,
          fields: fields,
          // TODO: obtain iconUrl based on url
          // iconUrl: iconUrl.value,
          uris: [url],
          // appIds: appIds, // TODO: obtain app id from app uri
          metadata: metadata,
          tags: [sourceFormat.id.toLowerCase()],
        );
      },
    ).toList();

    console.info(
      'items: ${items.length}, groupId: $groupId, format: $sourceFormat',
    );

    await ItemsService.to.box!.addAll(items);

    UIUtils.showSimpleDialog(
      'Import Successful',
      'Imported ${items.length} items via ${sourceFormat.title}',
    );

    return true;
  }
}
