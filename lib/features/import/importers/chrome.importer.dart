import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
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

const validColumns = [
  'name',
  'url',
  'username',
  'password',
];

class ChromeImporter {
  static final console = Console(name: 'ChromeImporter');

  static Future<bool> importCSV(String csv) async {
    final sourceFormat = ImportScreenController.to.sourceFormat.value;
    const csvConverter = CsvToListConverter();
    var values = csvConverter.convert(csv, eol: '\n');
    final columns = values.first.map((e) => e.trim()).toList();
    // exclude first row (column titles)
    values = values.sublist(1, values.length);

    if (!listEquals(columns, validColumns)) {
      console.error('$columns -> $validColumns');

      await UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid ${sourceFormat.title} exported file',
      );

      return false;
    }

    final metadata = await HiveMetadata.get();
    final destinationGroupId =
        ImportScreenController.to.destinationGroupId.value;
    String groupId = destinationGroupId;

    final items = values.map(
      (row) async {
        final name = row[0];
        final url = row[1];
        final username = row[2];
        final password = row[3];

        // group
        if (destinationGroupId == kSmartGroupId) {
          // use personal
          groupId = GroupsController.to.reserved.first.id;
        }

        // category
        final category = CategoriesController.to.reserved.firstWhere(
          (e) => e.id == LisoItemCategory.login.name,
        );

        final fields = category.fields.map((e) {
          if (e.identifier == 'website') {
            e.data.value = url;
          } else if (e.identifier == 'username') {
            e.data.value = username;
          } else if (e.identifier == 'password') {
            e.data.value = password;
          } else if (e.identifier == 'note') {
            e.data.value = '';
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
          uris: url.isNotEmpty ? [url] : [],
          // appIds: appIds, // TODO: obtain app id from app uri
          // protected: reprompt == '1',
          // favorite: favorite == '1',
          metadata: metadata,
          tags: [sourceFormat.id.toLowerCase()],
        );
      },
    );

    console.info(
      'items: ${items.length}, groupId: $groupId, format: ${sourceFormat.title}',
    );

    final items_ = await Future.wait(items);
    await ItemsService.to.box!.addAll(items_);

    final itemIds = items_.map((e) => e.identifier);
    MainScreenController.to.importedItemIds.addAll(itemIds);

    NotificationsManager.notify(
      title: 'Import Successful',
      body: 'Imported ${items.length} items via ${sourceFormat.title}',
    );

    return true;
  }
}
