import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/utils.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/utils/biometric.util.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/main/main_screen.controller.dart';

import '../hive/hive.manager.dart';
import 'liso_paths.dart';

class LisoManager {
  static final console = Console(name: 'LisoManager');

  static Future<void> reset() async {
    // delete biometric storage
    final storage = await BiometricUtils.getStorage();
    await storage.delete();

    // nullify global variables
    encryptionKey = null;
    masterWallet = null;

    // delete liso wallet file
    final file = File('${LisoPaths.main!.path}/$kLocalMasterWalletFileName');

    if (await file.exists()) {
      await file.delete();
      console.info('deleted: ${file.path}');
    }

    // cancel hive boxes' stream subscriptions
    MainScreenController.to.unwatchBoxes();
    // reset hive
    await HiveManager.reset();

    // persistence
    await PersistenceController.to.box.erase();

    // delete FilePicker caches
    if (GetPlatform.isMobile) {
      await FilePicker.platform.clearTemporaryFiles();
    }

    console.info('reset!');
  }
}
