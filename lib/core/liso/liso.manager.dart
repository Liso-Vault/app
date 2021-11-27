import 'dart:io';

import 'package:hive/hive.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path_provider/path_provider.dart';

class LisoManager {
  static final console = Console(name: 'LisoManager');

  static Future<void> init() async {
    final cipher = HiveAesCipher(encryptionKey!);

    try {
      HiveManager.seeds = await Hive.openBox('seeds', encryptionCipher: cipher);
    } on HiveError {
      console.error('HiveError');
      await HiveManager.fixCorruptedBox();
    }

    console.warning('seeds: ${HiveManager.seeds!.length}');
  }

  static Future<bool> authenticated() async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/$kLocalMasterWalletFileName');
    return await file.exists();
  }

  static Future<void> reset() async {
    encryptionKey = null;

    // wallet file
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/$kLocalMasterWalletFileName');
    if (await file.exists()) await file.delete();

    // hives
    Hive.deleteBoxFromDisk('seeds');

    // persistence
    await PersistenceController.to.box.erase();

    console.info('successfully reset!');
  }
}
