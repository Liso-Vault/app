import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';

import 'controllers/persistence.controller.dart';
import 'hive/hive.manager.dart';

class AppManager {
  static final console = Console(name: 'AppManager');

  static Future<void> init() async {
    // load saved encryption key
    const storage = FlutterSecureStorage();
    final encryptionKeyString = await storage.read(key: kEncryptionKey);
    encryptionKey = base64.decode(encryptionKeyString!);
    // decrypt hive box
    final cipher = HiveAesCipher(encryptionKey!);
    HiveManager.seeds = await Hive.openBox('seeds', encryptionCipher: cipher);
    console.warning('seeds: ${HiveManager.seeds!.length}');
  }

  static Future<bool> authenticated() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: kEncryptionKey) != null;
  }

  static void reset() async {
    encryptionKey = null;

    // hives
    Hive.deleteFromDisk();

    // secure storage
    await const FlutterSecureStorage().deleteAll();

    // persistence
    await PersistenceController.to.box.erase();

    console.info('successfully reset!');
  }
}
