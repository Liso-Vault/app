import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/utils.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';

import 'liso_paths.dart';

class LisoManager {
  static final console = Console(name: 'LisoManager');

  static Future<void> init() async {
    HiveManager.archived = await Hive.openBox(kHiveBoxArchived);
    HiveManager.trash = await Hive.openBox(kHiveBoxTrash);
    HiveManager.favorites = await Hive.openBox(kHiveBoxFavorites);

    HiveManager.items = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher: HiveAesCipher(encryptionKey!),
    );

    console.warning('items: ${HiveManager.items!.length}');
  }

  static Future<bool> authenticated() async {
    final file = File('${LisoPaths.main!.path}/$kLocalMasterWalletFileName');
    return await file.exists();
  }

  static Future<void> reset() async {
    encryptionKey = null;
    masterWallet = null;

    // master wallet file
    final file = File('${LisoPaths.main!.path}/$kLocalMasterWalletFileName');

    if (await file.exists()) {
      await file.delete();
      console.info('deleted: ${file.path}');
    }

    // hives
    Hive.deleteFromDisk();

    // persistence
    await PersistenceController.to.box.erase();

    // delete FilePicker caches
    if (GetPlatform.isMobile) {
      await FilePicker.platform.clearTemporaryFiles();
    }

    console.info('reset!');
  }
}
