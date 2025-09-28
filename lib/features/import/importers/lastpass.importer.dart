import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

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
        var url = row[0].toString();
        final username = row[1].toString();
        final password = row[2].toString();
        final totp = row[3].toString();
        final extra = row[4].toString(); // TODO: work on custom fields
        final name = row[5].toString();
        var grouping = row[6].toString();
        final favorite = row[7] == 1;
        final hasCustomFields = extra.contains('NoteType:');
        final isLastPassUri =
            url.contains('http://sn') || url.contains('http://xn');

        // if has sub folder, use the sub folder
        if (grouping.contains(r'\')) {
          grouping = grouping.split(r'\').last;
          console.warning('sub folder: $grouping');
        }

        // generate group if doesn't exist
        if (destinationGroupId == kSmartGroupId) {
          if (grouping.isEmpty) {
            // use personal
            groupId = GroupsController.to.reserved.first.id;
          } else {
            // generate the id
            groupId = '${grouping.toLowerCase().trim()}-${sourceFormat.id}';

            final exists = GroupsController.to.data
                .where((e) => e.id == groupId)
                .isNotEmpty;

            if (!exists) {
              await GroupsService.to.box!.add(
                HiveLisoGroup(
                  id: groupId,
                  name: grouping,
                  description: 'Imported via ${sourceFormat.title}',
                  metadata: metadata,
                ),
              );

              console.wtf('generated group: $groupId');
            }
          }
        }

        console.wtf('groupId: #$groupId#');

        // default category
        var itemCategory = LisoItemCategory.login;
        String noteType = '';
        // default notes
        String notes = extra;
        // holder for custom field rows Key:Value
        List<String> customFieldRows = [];
        // if it's a secure note category
        if (url == 'http://sn' && !hasCustomFields) {
          itemCategory = LisoItemCategory.note;
          notes = extra; // parse Notes:
        }
        // if this is a another type than notes
        else if (hasCustomFields) {
          itemCategory = LisoItemCategory.custom;
          // extract custom field rows
          customFieldRows = extra.split('\n');
          // grab the category
          noteType = customFieldRows.first.split(':').last;
          // exclude 1st and 2nd row (NoteType and Language)
          customFieldRows = customFieldRows.sublist(2, customFieldRows.length);
          // grab the notes
          notes = customFieldRows.last.split(':').last;
          // remove the notes
          customFieldRows.removeLast();
        }

        console.wtf(
          'category: ${itemCategory.name}, noteType: $noteType, grouping: $grouping, custom fields: ${customFieldRows.length}',
        );

        final category = CategoriesController.to.reserved.firstWhere(
          (e) => e.id == itemCategory.name,
        );

        var fields = category.fields.map((e) {
          if (e.identifier == 'website') {
            e.data.value = isLastPassUri ? '' : url;
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
          uris: isLastPassUri ? [] : [url],
          // appIds: appIds, // TODO: obtain app id from app uri
          // protected: reprompt == 1,
          favorite: favorite == 1,
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
