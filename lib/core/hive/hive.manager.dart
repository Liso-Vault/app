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
  static Box<HiveLisoItem>? items;
  static StreamSubscription? itemsStream;

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
    final cipher = HiveAesCipher(Globals.encryptionKey);

    items = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher: cipher,
      path: LisoManager.hivePath,
    );

    watchBoxes();
    console.info('openBoxes');
  }

  static Future<void> closeBoxes() async {
    if (items?.isOpen == true) await items?.close();
    unwatchBoxes();
    console.info('closeBoxes');
  }

  static void watchBoxes() {
    itemsStream = items?.watch().listen(MainScreenController.to.onBoxChanged);
    console.info('watchBoxes');
  }

  static Future<void> unwatchBoxes() async {
    await itemsStream?.cancel();
    console.info('unwatchBoxes');
  }

  static Future<void> deleteBoxes() async {
    await items?.deleteFromDisk();
    console.info('deleteBoxes');
  }

  // workaround to check if encryption key is correct
  static Future<bool> isEncryptionKeyCorrect(List<int> key) async {
    // initialize as a temporary hive box
    final _items = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher: HiveAesCipher(key),
      path: LisoManager.tempPath,
    );

    // TODO: what if vault is literally empty
    final correct = _items.isNotEmpty;
    _items.close();
    return correct;
  }

  static Future<void> reset() async {
    await closeBoxes();
    await deleteBoxes();
    items = null;
    console.info('reset');
  }
}
