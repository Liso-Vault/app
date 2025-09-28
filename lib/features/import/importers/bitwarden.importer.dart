import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/hive/models/field.hive.dart';
import '../../../core/hive/models/group.hive.dart';
import '../../../core/hive/models/item.hive.dart';
import '../../../core/hive/models/metadata/metadata.hive.dart';
import '../../../core/utils/globals.dart';
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
    final autoTag = ImportScreenController.to.autoTag.value;
    const csvConverter = CsvToListConverter();
    var values = csvConverter.convert(csv, eol: '\n');
    final columns = values.first.map((e) => e.trim()).toList();
    // exclude first row (column titles)
    values = values.sublist(1, values.length);

    if (!listEquals(columns, validColumns)) {
      console.error('$columns -> $validColumns');

      await UIUtils.showSimpleDialog(
        'invalid_csv_columns'.tr,
        '${'please_import_a_valid_exported_file'.tr} (${sourceFormat.title})',
      );

      return false;
    }

    final metadata = await HiveMetadata.get();
    final destinationGroupId =
        ImportScreenController.to.destinationGroupId.value;
    String groupId = destinationGroupId;

    final items = values.map(
      (row) async {
        final folder = row[0].toString();
        final favorite = row[1] == 1;
        final type = row[2].toString();
        final name = row[3].toString();
        final notes = row[4].toString();
        final bitwardenFields = row[5].toString();
        final reprompt = row[6] == 1;
        final url = row[7].toString();
        final username = row[8].toString();
        final password = row[9].toString();
        final totp = row[10].toString();

        // generate group if doesn't exist
        if (destinationGroupId == kSmartGroupId) {
          if (folder.isEmpty) {
            // use personal
            groupId = GroupsController.to.reserved.first.id;
          } else {
            // generate the id
            groupId = '${folder.toLowerCase().trim()}-${sourceFormat.id}';

            final exists = GroupsController.to.data
                .where((e) => e.id == groupId)
                .isNotEmpty;

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
        }

        // category
        var itemCategory = LisoItemCategory.login;
        if (type == 'note') itemCategory = LisoItemCategory.note;
        // holder for custom field rows Key:Value
        var customFieldRows = bitwardenFields.split('\n');

        console.wtf(
          'category: ${itemCategory.name}, folder: $folder, custom fields: ${customFieldRows.length}',
        );

        final category = CategoriesController.to.reserved.firstWhere(
          (e) => e.id == itemCategory.name,
        );

        // TODO: parse null, booleans
        var fields = category.fields.map((e) {
          if (e.identifier == 'website') {
            e.data.value = url;
          } else if (e.identifier == 'username') {
            e.data.value = username;
          } else if (e.identifier == 'password') {
            e.data.value = password;
          } else if (e.identifier == 'totp') {
            e.data.value = totp.trim();
          }

          if (category.id == LisoItemCategory.note.name) {
            if (e.identifier == 'secure_note') {
              e.data.value = '[{"insert":"$notes\\n"}]';
            }
          } else if (e.identifier == 'note') {
            e.data.value = notes;
          }

          return e;
        }).toList();

        final customFields = customFieldRows.map((e) {
          final pair = e.split(':');
          final label = pair.first;
          final value = pair.last;

          return HiveLisoField(
            identifier: const Uuid().v4(), // generate
            type: LisoFieldType.textField.name,
            data: HiveLisoFieldData(label: label, value: value),
          );
        }).toList();

        // insert before the default note field
        fields.insertAll(fields.length - 1, customFields);

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
          protected: reprompt,
          favorite: favorite,
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
      title: 'import_successful'.tr,
      body: 'Imported ${items.length} items via ${sourceFormat.title}',
    );

    return true;
  }
}
