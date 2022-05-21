import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/metadata/app.hive.dart';
import 'package:liso/core/hive/models/metadata/device.hive.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../liso/liso_paths.dart';
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
  static bool get itemLimitReached =>
      items!.length >= WalletService.to.limits.items;

  static bool get protectedItemLimitReached =>
      items!.length >= WalletService.to.limits.items;

  // INIT
  static Future<void> init() async {
    // PATH
    if (!GetPlatform.isWeb) Hive.init(LisoPaths.hivePath);
    // REGISTER ADAPTERS
    // liso
    Hive.registerAdapter(HiveLisoItemAdapter());
    Hive.registerAdapter(HiveLisoFieldAdapter());
    Hive.registerAdapter(HiveLisoFieldDataAdapter());
    Hive.registerAdapter(HiveLisoFieldChoicesAdapter());
    // metadata
    Hive.registerAdapter(HiveMetadataAdapter());
    Hive.registerAdapter(HiveMetadataAppAdapter());
    Hive.registerAdapter(HiveMetadataDeviceAdapter());
    console.info("init");
  }

  static Future<void> open({Uint8List? cipherKey}) async {
    items = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher: HiveAesCipher(cipherKey ?? WalletService.to.cipherKey!),
      path: LisoPaths.hivePath,
    );

    console.info('openBoxes');
  }

  static Future<void> close() async {
    if (items?.isOpen == true) await items?.close();
    await unwatchBoxes();
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

  static Future<File> export({required String path}) async {
    // TODO: isolate
    final jsonString = jsonEncode(items!.values.toList());
    final file = File(path);
    await file.writeAsString(jsonString);
    return await CipherService.to.encryptFile(file);
  }

  static Future<List<HiveLisoItem>> parseVaultFile(File file,
      {Uint8List? cipherKey}) async {
    final decryptedFile = await CipherService.to.decryptFile(
      file,
      cipherKey: cipherKey,
    );

    final jsonString = await decryptedFile.readAsString();
    // TODO: isolate
    final jsonMap = jsonDecode(jsonString);

    final importedItems = List<HiveLisoItem>.from(
      jsonMap.map((x) => HiveLisoItem.fromJson(x)),
    );

    return importedItems;
  }

  static Future<void> importVaultFile(File file, {Uint8List? cipherKey}) async {
    // parse vault to items
    final items_ = await parseVaultFile(file, cipherKey: cipherKey);
    // open database
    await open(cipherKey: cipherKey!);
    // populate database
    items!.addAll(items_);
  }

  static Future<void> reset() async {
    await items?.deleteFromDisk();
    items = null;
    console.info('reset');
  }
}
