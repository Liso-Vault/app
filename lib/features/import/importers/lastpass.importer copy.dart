// import 'package:console_mixin/console_mixin.dart';
// import 'package:csv/csv.dart';
// import 'package:flutter/foundation.dart';
// import 'package:liso/core/hive/models/field.hive.dart';
// import 'package:uuid/uuid.dart';

// import '../../../core/hive/models/group.hive.dart';
// import '../../../core/hive/models/item.hive.dart';
// import '../../../core/hive/models/metadata/metadata.hive.dart';
// import '../../../core/utils/globals.dart';
// import '../../../core/utils/ui_utils.dart';
// import '../../categories/categories.controller.dart';
// import '../../groups/groups.controller.dart';
// import '../../groups/groups.service.dart';
// import '../import_screen.controller.dart';

// const validColumns = [
//   'url',
//   'username',
//   'password',
//   'totp',
//   'extra',
//   'name',
//   'grouping',
//   'fav'
// ];

// class LastPassImporter {
//   static final console = Console(name: 'LastPassImporter');

//   static Future<bool> importCSV(String csv) async {
//     final sourceFormat = ImportScreenController.to.sourceFormat.value;
//     const csvConverter = CsvToListConverter();
//     var values = csvConverter.convert(csv, eol: '\n');
//     final columns = values.first.map((e) => e.trim()).toList();
//     // exclude first row (column titles)
//     values = values.sublist(1, values.length);

//     if (!listEquals(columns, validColumns)) {
//       await UIUtils.showSimpleDialog(
//         'Invalid CSV Columns',
//         'Please import a valid ${sourceFormat.title} exported file',
//       );

//       return false;
//     }

//     final metadata = await HiveMetadata.get();
//     String groupId = ImportScreenController.to.destinationGroupId.value;

//     final items = values.map(
//       (row) async {
//         final url = row[0];
//         final username = row[1];
//         final password = row[2];
//         final totp = row[3];
//         final extra = row[4]; // TODO: work on custom fields
//         final name = row[5];
//         var grouping = row[6];
//         final favorite = row[7];
//         final hasCustomFields = extra.contains('NoteType:');

//           // if has sub folder, use the sub folder
//           if (grouping.contains('\\')) {
//             grouping = grouping.split('\\').last;
//             console.warning('sub folder: $grouping');
//           }

//         // generate group if doesn't exist
//         if (groupId == kSmartGroupId && grouping.isNotEmpty) {

//           // generate the id
//           groupId = '${grouping.toLowerCase().trim()}-${sourceFormat.id}';
//           final exists =
//               GroupsController.to.data.where((e) => e.id == groupId).isEmpty;

//           if (!exists) {
//             await GroupsService.to.box!.add(
//               HiveLisoGroup(
//                 id: groupId,
//                 name: grouping,
//                 description: 'Imported via ${sourceFormat.title}',
//                 metadata: metadata,
//               ),
//             );

//             console.wtf('generated group: $groupId');
//           }
//         }

//         // default category
//         String categoryId = LisoItemCategory.login.name;
//         String noteType = '';
//         // default notes
//         String notes = extra;
//         // holder for custom field rows Key:Value
//         List<String> customFieldRows = [];
//         // if it's a secure note category
//         if (url == 'http://sn' && !hasCustomFields) {
//           categoryId = LisoItemCategory.note.name;
//           notes = extra; // parse Notes:
//         }
//         // if this is a another type than notes
//         else if (hasCustomFields) {
//           customFieldRows = extra.split('\n');
//           // grab the category
//           noteType = customFieldRows.first.split(':').last;
//           // exclude 1st and 2nd row (NoteType and Language)
//           customFieldRows = customFieldRows.sublist(2, customFieldRows.length);

//           if (noteType == 'Credit Card') {
//             categoryId = LisoItemCategory.cashCard.name;
//           } else if (noteType == 'Bank Account') {
//             categoryId = LisoItemCategory.bankAccount.name;
//           } else if (noteType == "Driver's License") {
//             categoryId = LisoItemCategory.driversLicense.name;
//           } else if (noteType == 'Passport') {
//             categoryId = LisoItemCategory.passport.name;
//           } else if (noteType == 'Social Security') {
//             categoryId = LisoItemCategory.socialSecurity.name;
//           } else if (noteType == 'Insurance') {
//             categoryId = LisoItemCategory.insurance.name;
//           } else if (noteType == 'Health Insurance') {
//             categoryId = LisoItemCategory.healthInsurance.name;
//           } else if (noteType == 'Membership') {
//             categoryId = LisoItemCategory.membership.name;
//           } else if (noteType == 'Wi-Fi Password') {
//             categoryId = LisoItemCategory.wirelessRouter.name;
//           } else if (noteType == 'Email Account') {
//             categoryId = LisoItemCategory.email.name;
//           } else if (noteType == 'Database') {
//             categoryId = LisoItemCategory.database.name;
//           } else if (noteType == 'SSH Key') {
//             categoryId = LisoItemCategory.encryption.name;
//           } else if (noteType == 'Software License') {
//             categoryId = LisoItemCategory.softwareLicense.name;
//           }
//           // use notes as there's no plan to support a specific address only template
//           else if (noteType == 'Address') {
//             categoryId = LisoItemCategory.note.name;
//           }
//           // use notes as there's no plan to support an IM template
//           else if (noteType == 'Instant Messenger') {
//             categoryId = LisoItemCategory.note.name;
//           }
//           // if it's a custom category, use notes
//           else {
//             categoryId = LisoItemCategory.note.name;
//           }

//           console.warning(
//             'category: $categoryId, fields: ${customFieldRows.length}',
//           );
//         }

//         final category = CategoriesController.to.reserved.firstWhere(
//           (e) => e.id == categoryId,
//         );

//         var fields = category.fields.map((e) {
//           // if (e.identifier == 'website') {
//           //   e.data.value = url;
//           // } else if (e.identifier == 'username') {
//           //   e.data.value = username;
//           // } else if (e.identifier == 'password') {
//           //   e.data.value = password;
//           // } else if (e.identifier == 'totp') {
//           //   e.data.value = totp.trim();
//           // } else if (e.identifier == 'note') {
//           //   e.data.value = notes;
//           // }

//           for (var r in customFieldRows) {
//             final pair = r.split(':');
//             final fieldName = pair.first;
//             final value = pair.last;

//             console.wtf('$fieldName => $value');

//             if (fieldName == 'Name on Card' && e.identifier == 'holder_name') {
//               e.data.value = value;
//             } else if (fieldName == 'Type' && e.identifier == 'type') {
//               e.data.value = value;
//             } else if (fieldName == 'Number' && e.identifier == 'xxx') {
//               e.data.value = value;
//             } else if (fieldName == 'Security Code' && e.identifier == 'xxx') {
//               e.data.value = value;
//             } else if (fieldName == 'Start Date' && e.identifier == 'xxx') {
//               e.data.value = value;
//             } else if (fieldName == 'Expiration Date' &&
//                 e.identifier == 'xxx') {
//               e.data.value = value;
//             } else if (fieldName == 'Notes' && e.identifier == 'note') {
//               e.data.value = value;
//             }

//             if (noteType == 'Credit Card') {
//             } else if (noteType == 'Bank Account') {
//               //
//             } else if (noteType == "Driver's License") {
//               //
//             } else if (noteType == 'Passport') {
//               //
//             } else if (noteType == 'Social Security') {
//               //
//             } else if (noteType == 'Insurance') {
//               //
//             } else if (noteType == 'Health Insurance') {
//               //
//             } else if (noteType == 'Membership') {
//               //
//             } else if (noteType == 'Wi-Fi Password') {
//               //
//             } else if (noteType == 'Email Account') {
//               //
//             } else if (noteType == 'Database') {
//               //
//             } else if (noteType == 'SSH Key') {
//               //
//             } else if (noteType == 'Software License') {
//               //
//             } else if (noteType == 'Address') {
//               //
//             } else if (noteType == 'Instant Messenger') {
//               //
//             }
//             // if it's a custom category, use notes
//             else {
//               categoryId = LisoItemCategory.note.name;
//             }

//             // customFields.add(HiveLisoField(
//             //   identifier: const Uuid().v4(), // generate
//             //   type: fieldType_,
//             //   data: HiveLisoFieldData(
//             //     label: ,
//             //     hint: ,
//             //     value: ,
//             //   ),
//             // ));
//           }

//           return e;
//         }).toList();

//         // convert string based custom field rows to actual field objects
//         var customFields = <HiveLisoField>[];

//         // for (var r in customFieldRows) {
//         //   final pair = r.split(':');
//         //   final fieldName = pair.first;
//         //   final value = pair.last;

//         //   console.wtf('$fieldName => $value');

//         //   fields = fields.map((e) {
//         //     if (fieldName == 'Name on Card' && e.identifier == 'holder_name') {
//         //       e.data.value = value;
//         //     } else if (fieldName == 'Type' && e.identifier == 'type') {
//         //       e.data.value = value;
//         //     } else if (fieldName == 'Number' && e.identifier == 'xxx') {
//         //       e.data.value = value;
//         //     } else if (fieldName == 'Security Code' && e.identifier == 'xxx') {
//         //       e.data.value = value;
//         //     } else if (fieldName == 'Start Date' && e.identifier == 'xxx') {
//         //       e.data.value = value;
//         //     } else if (fieldName == 'Expiration Date' &&
//         //         e.identifier == 'xxx') {
//         //       e.data.value = value;
//         //     } else if (fieldName == 'Notes' && e.identifier == 'note') {
//         //       e.data.value = value;
//         //     }

//         //     return e;
//         //   }).toList();

//         //   if (noteType == 'Credit Card') {
//         //   } else if (noteType == 'Bank Account') {
//         //     //
//         //   } else if (noteType == "Driver's License") {
//         //     //
//         //   } else if (noteType == 'Passport') {
//         //     //
//         //   } else if (noteType == 'Social Security') {
//         //     //
//         //   } else if (noteType == 'Insurance') {
//         //     //
//         //   } else if (noteType == 'Health Insurance') {
//         //     //
//         //   } else if (noteType == 'Membership') {
//         //     //
//         //   } else if (noteType == 'Wi-Fi Password') {
//         //     //
//         //   } else if (noteType == 'Email Account') {
//         //     //
//         //   } else if (noteType == 'Database') {
//         //     //
//         //   } else if (noteType == 'SSH Key') {
//         //     //
//         //   } else if (noteType == 'Software License') {
//         //     //
//         //   } else if (noteType == 'Address') {
//         //     //
//         //   } else if (noteType == 'Instant Messenger') {
//         //     //
//         //   }
//         //   // if it's a custom category, use notes
//         //   else {
//         //     categoryId = LisoItemCategory.note.name;
//         //   }

//         // customFields.add(HiveLisoField(
//         //   identifier: const Uuid().v4(), // generate
//         //   type: fieldType_,
//         //   data: HiveLisoFieldData(
//         //     label: ,
//         //     hint: ,
//         //     value: ,
//         //   ),
//         // ));
//         // }

//         // insert before the default note field
//         // fields.insertAll(fields.length - 1, customFields);

//         return HiveLisoItem(
//           identifier: const Uuid().v4(),
//           groupId: groupId,
//           category: category.id,
//           title: name,
//           fields: fields,
//           // TODO: obtain iconUrl based on url
//           // iconUrl: iconUrl.value,
//           uris: url.isNotEmpty ? [url] : [],
//           // appIds: appIds, // TODO: obtain app id from app uri
//           // protected: reprompt == 1,
//           favorite: favorite == 1,
//           metadata: metadata,
//           tags: [sourceFormat.id.toLowerCase()],
//         );
//       },
//     );

//     console.info(
//       'items: ${items.length}, groupId: $groupId, format: ${sourceFormat.title}',
//     );

//     final items_ = await Future.wait(items);
//     // await ItemsService.to.box!.addAll(items_);

//     // final itemIds = items_.map((e) => e.identifier);
//     // MainScreenController.to.importedItemIds.addAll(itemIds);

//     // NotificationsService.to.notify(
//     //   title: 'Import Successful',
//     //   body: 'Imported ${items.length} items via ${sourceFormat.title}',
//     // );

//     return true;
//   }
// }
