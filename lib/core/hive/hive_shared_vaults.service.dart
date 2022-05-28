import 'dart:async';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/shared_vault.hive.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../liso/liso_paths.dart';
import '../utils/globals.dart';

class HiveSharedVaultsService extends GetxService with ConsoleMixin {
  static HiveSharedVaultsService get to => Get.find<HiveSharedVaultsService>();

  // VARIABLES
  late Box<HiveSharedVault> box;

  // GETTERS
  List<HiveSharedVault> get data => box.values.toList();

  // FUNCTIONS

  Future<void> open({Uint8List? cipherKey}) async {
    box = await Hive.openBox(
      kHiveBoxSharedVaultItems,
      encryptionCipher: HiveAesCipher(cipherKey ?? WalletService.to.cipherKey!),
      path: LisoPaths.hivePath,
    );
  }

  Future<void> close() async {
    await box.close();
    console.info('close');
  }

  Future<void> clear() async {
    await box.deleteFromDisk();
    console.info('reset');
  }
}
