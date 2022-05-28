import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive.service.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/drawer/drawer_widget.controller.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

class LisoManager {
  // VARIABLES
  static final console = Console(name: 'LisoManager');

  // GETTERS

  // FUNCTIONS

  static Future<void> reset() async {
    console.info('resetting...');
    // clear filters
    DrawerMenuController.to.clearFilters();
    // reset hive
    await HiveService.to.clear();
    // reset wallet
    WalletService.to.reset();
    // reset persistence
    await Persistence.reset();
    // delete FilePicker caches
    if (GetPlatform.isMobile) {
      await FilePicker.platform.clearTemporaryFiles();
    }

    // reset s3 minio client
    S3Service.to.init();
    console.info('reset!');
  }
}
