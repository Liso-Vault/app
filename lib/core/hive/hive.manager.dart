import 'dart:async';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/metadata/app.hive.dart';
import 'package:liso/core/hive/models/metadata/device.hive.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/main/main_screen.controller.dart';

import '../liso/liso.manager.dart';
import '../utils/globals.dart';
import 'models/field.hive.dart';
import 'models/item.hive.dart';
import 'models/metadata/metadata.hive.dart';

class HiveManager {
  static final console = Console(name: 'HiveManager');

  // VARIABLES
  static Box<HiveLisoItem>? items, archived, trash;
  static StreamSubscription? itemsStream, archivedStream, trashStream;

  // GETTERS

  // INIT
  static Future<void> init() async {
    // PATH
    if (!GetPlatform.isWeb) Hive.init(LisoManager.hivePath);
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
      encryptionCipher: HiveAesCipher(Globals.encryptionKey!),
    );

    archived = await Hive.openBox(
      kHiveBoxArchived,
      encryptionCipher: HiveAesCipher(Globals.encryptionKey!),
    );

    trash = await Hive.openBox(
      kHiveBoxTrash,
      encryptionCipher: HiveAesCipher(Globals.encryptionKey!),
    );

    _watchBoxes();
    console.info('openBoxes');
  }

  static Future<void> closeBoxes() async {
    if (items?.isOpen == true) await items?.close();
    if (archived?.isOpen == true) await archived?.close();
    if (trash?.isOpen == true) await trash?.close();
    await _unwatchBoxes();
    console.info('closeBoxes');
  }

  static void _watchBoxes() {
    final mainController = Get.find<MainScreenController>();
    itemsStream = items?.watch().listen(mainController.onBoxChanged);
    archivedStream = archived?.watch().listen(mainController.onBoxChanged);
    trashStream = trash?.watch().listen(mainController.onBoxChanged);
    console.info('watchBoxes');
  }

  static Future<void> _unwatchBoxes() async {
    await itemsStream?.cancel();
    await archivedStream?.cancel();
    await trashStream?.cancel();
    console.info('unwatchBoxes');
  }

  // workaround to check if encryption key is correct
  static Future<bool> isEncryptionKeyCorrect(List<int> key) async {
    // initialize as a temporary hive box
    final _items = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher: HiveAesCipher(key),
      path: LisoManager.tempPath,
    );

    final correct = _items.isNotEmpty;
    // delete box after use
    await Hive.deleteBoxFromDisk(kHiveBoxItems, path: LisoManager.tempPath);
    return correct;
  }

  static Future<void> reset() async {
    await closeBoxes();
    await Hive.deleteFromDisk();
    items = null;
    archived = null;
    trash = null;
    console.info('reset');
  }
}
