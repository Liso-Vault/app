import 'package:get/get_utils/src/platform/platform.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/metadata/app.hive.dart';
import 'package:liso/core/hive/models/metadata/device.hive.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/utils/console.dart';
import 'package:path/path.dart';

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
    items = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher: HiveAesCipher(encryptionKey!),
    );

    archived = await Hive.openBox(
      kHiveBoxArchived,
      encryptionCipher: HiveAesCipher(encryptionKey!),
    );

    trash = await Hive.openBox(
      kHiveBoxTrash,
      encryptionCipher: HiveAesCipher(encryptionKey!),
    );
  }

  // workaround to check if encryption key is correct
  static Future<bool> isEncryptionKeyCorrect(List<int> key) async {
    // initialize as a temporary hive box
    final _items = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher: HiveAesCipher(key),
      path: LisoPaths.temp!.path,
    );

    final correct = _items.isNotEmpty;
    // delete box after use
    await Hive.deleteBoxFromDisk(kHiveBoxItems, path: LisoPaths.temp!.path);
    return correct;
  }

  static Future<void> reset() async {
    await Hive.deleteFromDisk();

    items = null;
    archived = null;
    trash = null;

    console.info('reset');
  }
}
