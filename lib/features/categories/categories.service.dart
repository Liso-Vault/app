import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';

import '../../core/hive/models/category.hive.dart';
import '../../core/liso/liso_paths.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/utils/globals.dart';
import 'categories.controller.dart';

class CategoriesService extends GetxService with ConsoleMixin {
  static CategoriesService get to => Get.find<CategoriesService>();

  // VARIABLES
  Box<HiveLisoCategory>? box;
  bool boxInitialized = false;

  // GETTERS
  List<HiveLisoCategory> get data =>
      box != null && box!.isOpen ? box!.values.toList() : [];

  // FUNCTIONS

  Future<void> open({Uint8List? cipherKey, bool initialize = true}) async {
    if (Hive.isBoxOpen(kHiveBoxCategories)) return;
    final cipher = HiveAesCipher(cipherKey ?? SecretPersistence.to.cipherKey);

    box = await Hive.openBox(
      kHiveBoxCategories,
      encryptionCipher: cipher,
      path: LisoPaths.hivePath,
    );

    boxInitialized = true;
    // console.info('length: ${data.length}');
  }

  Future<void> close() async {
    await box?.close();
    // console.info('close');
  }

  Future<void> clear() async {
    if (box?.isOpen == false) return;

    if (!boxInitialized) {
      await File(join(LisoPaths.hivePath, '$kHiveBoxCategories.hive')).delete();
      return;
    }

    await box?.clear();
    // refresh custom categories
    CategoriesController.to.load();
    await box?.deleteFromDisk();
    // console.info('clear');
  }

  Future<void> import(List<HiveLisoCategory> data,
      {Uint8List? cipherKey}) async {
    await open(cipherKey: cipherKey, initialize: false);
    await box?.clear();
    box?.addAll(data);
  }
}
