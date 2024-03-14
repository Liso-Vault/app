import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:uuid/uuid.dart';

import '../../../core/hive/models/item.hive.dart';
import '../../../core/hive/models/metadata/metadata.hive.dart';
import '../../categories/categories.controller.dart';
import '../../groups/groups.controller.dart';
import '../import_screen.controller.dart';

const validColumns = [
  'url',
  'username',
  'password',
  'httpRealm',
  'formActionOrigin',
  'guid',
  'timeCreated',
  'timeLastUsed',
  'timePasswordChanged',
];

class FirefoxImporter {
  static final console = Console(name: 'FirefoxImporter');

  static Future<bool> importCSV(String csv) async {
    final sourceFormat = ImportScreenController.to.sourceFormat.value;
    final autoTag = ImportScreenController.to.autoTag.value;
    const csvConverter = CsvToListConverter();
    var values = csvConverter.convert(csv);
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
        final url = row[0].toString();
        final username = row[1].toString();
        final password = row[2].toString();

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
          }

          return e;
        }).toList();

        return HiveLisoItem(
          identifier: const Uuid().v4(),
          groupId: groupId,
          category: category.id,
          title: url,
          fields: fields,
          // TODO: obtain iconUrl based on url
          // iconUrl: iconUrl.value,
          uris: url.isNotEmpty ? [url] : [],
          // appIds: appIds, // TODO: obtain app id from app uri
          // protected: reprompt == '1',
          // favorite: favorite == '1',
          metadata: metadata,
          tags: autoTag ? [sourceFormat.id.toLowerCase()] : [],
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

    NotificationsService.to.notify(
      title: 'Import Successful',
      body: 'Imported ${items.length} items via ${sourceFormat.title}',
    );

    return true;
  }
}
