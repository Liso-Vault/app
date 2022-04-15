import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/utils.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/biometric.util.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/extensions.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:path/path.dart';

import '../hive/hive.manager.dart';
import '../utils/ui_utils.dart';
import 'liso_paths.dart';

class LisoManager {
  // VARIABLES
  static final console = Console(name: 'LisoManager');

  // GETTERS
  String get fileName => masterWallet!.fileName;

  // FUNCTIONS
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
    await PersistenceService.to.box.erase();

    // delete FilePicker caches
    if (GetPlatform.isMobile) {
      await FilePicker.platform.clearTemporaryFiles();
    }

    console.info('reset!');
  }

  static Future<File?> archive() async {
    console.info('archiving...');

    final encoder = ZipFileEncoder();
    final filePath = join(LisoPaths.temp!.path, masterWallet!.fileName);

    try {
      encoder.create(filePath);
      await encoder.addDirectory(Directory(LisoPaths.hive!.path));
      encoder.close();
    } catch (e) {
      UIUtils.showSimpleDialog(
        'Error Archiving Vault',
        e.toString() + ' > archive()',
      );

      return null;
    }

    return File(filePath);
  }
}
