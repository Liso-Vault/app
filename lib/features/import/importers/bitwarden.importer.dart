import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/hive/models/group.hive.dart';
import '../../../core/hive/models/item.hive.dart';
import '../../../core/hive/models/metadata/metadata.hive.dart';
import '../../../core/notifications/notifications.manager.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/ui_utils.dart';
import '../../categories/categories.controller.dart';
import '../../groups/groups.controller.dart';
import '../../groups/groups.service.dart';
import '../../items/items.service.dart';
import '../../main/main_screen.controller.dart';
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
  'login_totp',
];

class BitwardenImporter {
  static final console = Console(name: 'BitwardenImporter');

  static Future<bool> importCSV(String csv) async {
    final sourceFormat = ImportScreenController.to.sourceFormat.value;
    const csvConverter = CsvToListConverter();
    var values = csvConverter.convert(csv, eol: '\n');
    final columns = values.first.map((e) => e.trim()).toList();
    // exclude first row (column titles)
    values = values.sublist(1, values.length);

    if (!listEquals(columns, validColumns)) {
      await UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid ${sourceFormat.title} exported file',
      );

      return false;
    }

    final metadata = await HiveMetadata.get();
    String groupId = ImportScreenController.to.destinationGroupId.value;

    final items = values.map(
      (row) async {
        final folder = row[0];
        final favorite = row[1];
        final type = row[2];
        final name = row[3];
        final notes = row[4];
        final customFields = row[5]; // TODO: work on custom fields
        final reprompt = row[6];
        final url = row[7];
        final username = row[8];
        final password = row[9];
        final totp = row[10];

        // generate group if doesn't exist
        if (groupId == 'smart-vault-destination' && folder.isNotEmpty) {
          // generate the id
          groupId = '${folder.toLowerCase().trim()}-${sourceFormat.id}';
          final exists =
              GroupsController.to.data.where((e) => e.id == groupId).isEmpty;

          if (!exists) {
            await GroupsService.to.box!.add(
              HiveLisoGroup(
                id: groupId,
                name: folder,
                description: 'Imported via ${sourceFormat.title}',
                metadata: metadata,
              ),
            );

            console.wtf('generated group: $groupId');
          }
        }

        // category
        String categoryId = LisoItemCategory.login.name;

        if (type == 'note') {
          categoryId = LisoItemCategory.note.name;
        }

        final category = CategoriesController.to.combined.firstWhere(
          (e) => e.id == categoryId,
        );

        final fields = category.fields.map((e) {
          if (e.identifier == 'website') {
            e.data.value = url;
          } else if (e.identifier == 'username') {
            e.data.value = username;
          } else if (e.identifier == 'password') {
            e.data.value = password;
          } else if (e.identifier == 'totp') {
            e.data.value = totp.trim();
          } else if (e.identifier == 'note') {
            e.data.value = notes;
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
          protected: reprompt == 1,
          favorite: favorite == 1,
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
