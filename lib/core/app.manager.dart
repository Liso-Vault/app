import 'dart:io';

import 'package:hive/hive.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path_provider/path_provider.dart';

import 'controllers/persistence.controller.dart';
import 'hive/hive.manager.dart';

class AppManager {
  static final console = Console(name: 'AppManager');

  static Future<void> init() async {
    final cipher = HiveAesCipher(encryptionKey!);
    HiveManager.seeds = await Hive.openBox('seeds', encryptionCipher: cipher);
    console.warning('seeds: ${HiveManager.seeds!.length}');
  }

  static Future<bool> authenticated() async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/$kVaultFileName');
    return await file.exists();
  }

  static Future<void> reset() async {
    encryptionKey = null;

    // wallet file
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/$kVaultFileName');
    if (await file.exists()) await file.delete();

    // hives
    Hive.deleteBoxFromDisk('seeds');

    // persistence
    await PersistenceController.to.box.erase();

    console.info('successfully reset!');
  }
}
