import 'package:get/get_utils/src/platform/platform.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/metadata/app.hive.dart';
import 'package:liso/core/hive/models/metadata/device.hive.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/utils/console.dart';

import '../utils/globals.dart';
import 'models/field.hive.dart';
import 'models/item.hive.dart';
import 'models/metadata/metadata.hive.dart';

class HiveManager {
  static final console = Console(name: 'HiveManager');

  // VARIABLES
  static Box<HiveLisoItem>? items, archived, trash;

  // GETTERS

  // INIT
  static Future<void> init() async {
    // PATH
    if (!GetPlatform.isWeb) {
      Hive.init(LisoPaths.hive!.path);
    }

    // REGISTER ADAPTERS
    // liso
    Hive.registerAdapter(HiveLisoItemAdapter());
    Hive.registerAdapter(HiveLisoFieldAdapter());
    // metadata
    Hive.registerAdapter(HiveMetadataAdapter());
    Hive.registerAdapter(HiveMetadataAppAdapter());
    Hive.registerAdapter(HiveMetadataDeviceAdapter());

    console.info("init");
  }

  static Future<void> openBoxes() async {
    HiveManager.items = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher: HiveAesCipher(encryptionKey!),
    );

    HiveManager.archived = await Hive.openBox(
      kHiveBoxArchived,
      encryptionCipher: HiveAesCipher(encryptionKey!),
    );

    HiveManager.trash = await Hive.openBox(
      kHiveBoxTrash,
      encryptionCipher: HiveAesCipher(encryptionKey!),
    );
  }
}
