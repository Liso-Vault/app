import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/hive/models/item.hive.dart';
import '../../../core/hive/models/metadata/metadata.hive.dart';
import '../../../core/utils/globals.dart';
import '../../categories/categories.controller.dart';
import '../../groups/groups.controller.dart';
import '../../items/items.service.dart';
import '../../main/main_screen.controller.dart';
import '../import_screen.controller.dart';

const validColumns = [
  'Title',
  'URL',
  'Username',
  'Password',
  'Notes',
  'OTPAuth'
];

class AppleImporter {
  static final console = Console(name: 'AppleImporter');

  static Future<bool> importCSV(String csv) async {
    final sourceFormat = ImportScreenController.to.sourceFormat.value;
    final autoTag = ImportScreenController.to.autoTag.value;
    const csvConverter = CsvToListConverter();
    final values = csvConverter.convert(csv, eol: '\n');
    final columns = values.first.sublist(0, validColumns.length);

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
        final name = row[0].toString();
        final url = row[1].toString();
        final username = row[2].toString();
        final password = row[3].toString();
        final notes = row[4].toString();
        final otpAuth = row[5].toString();

        // group
        if (groupId == kSmartGroupId) {
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
            e.data.value = notes;
          } else if (e.identifier == 'totp') {
            // TODO: extract totp from &secret param of otpAuth
            // e.data.value = password;
          }

          return e;
        }).toList();

        final uris = <String>[url];
        if (otpAuth.isNotEmpty) uris.add(otpAuth);

        return HiveLisoItem(
          identifier: const Uuid().v4(),
          groupId: groupId,
          category: category.id,
          title: name,
          fields: fields,
          // TODO: obtain iconUrl based on url
          // iconUrl: iconUrl.value,
          uris: uris,
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
