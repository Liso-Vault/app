import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:path/path.dart';

import '../../features/categories/categories.controller.dart';
import '../liso/liso_paths.dart';
import '../utils/globals.dart';
import 'models/category.hive.dart';

class HiveCategoriesService extends GetxService with ConsoleMixin {
  static HiveCategoriesService get to => Get.find<HiveCategoriesService>();

  // VARIABLES
  Box<HiveLisoCategory>? box;
  bool boxInitialized = false;

  // GETTERS
  List<HiveLisoCategory> get data =>
      box != null && box!.isOpen ? box!.values.toList() : [];

  // FUNCTIONS

  Future<void> open({Uint8List? cipherKey, bool initialize = true}) async {
    box = await Hive.openBox(
      kHiveBoxCategories,
      encryptionCipher: HiveAesCipher(cipherKey ?? WalletService.to.cipherKey!),
      path: LisoPaths.hivePath,
    );

    boxInitialized = true;
    console.info('length: ${data.length}');
  }

  Future<void> close() async {
    await box!.close();
    console.info('close');
  }

  Future<void> clear() async {
    if (!boxInitialized) {
      await File(join(LisoPaths.hivePath, '$kHiveBoxCategories.hive')).delete();
      return;
    }

    await box!.clear();
    // refresh cusom categories
    CategoriesController.to.load();
    await box!.deleteFromDisk();
    console.info('clear');
  }

  Future<void> import(List<HiveLisoCategory> data,
      {Uint8List? cipherKey}) async {
    await open(cipherKey: cipherKey, initialize: false);
    box!.addAll(data);
  }

  Future<void> purge() async {
    await box!.clear();
  }
}
