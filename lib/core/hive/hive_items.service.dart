import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../features/main/main_screen.controller.dart';
import '../liso/liso_paths.dart';
import '../utils/globals.dart';
import 'models/item.hive.dart';

class HiveItemsService extends GetxService with ConsoleMixin {
  static HiveItemsService get to => Get.find<HiveItemsService>();

  // VARIABLES
  late Box<HiveLisoItem> box;

  // GETTERS
  List<HiveLisoItem> get data => box.isOpen ? box.values.toList() : [];

  bool get itemLimitReached => data.length >= WalletService.to.limits.items;

  bool get protectedItemLimitReached =>
      data.where((e) => e.protected).length >= WalletService.to.limits.items;

  // FUNCTIONS

  Future<void> open({Uint8List? cipherKey}) async {
    box = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher: HiveAesCipher(cipherKey ?? WalletService.to.cipherKey!),
      path: LisoPaths.hivePath,
    );
  }

  Future<void> close() async {
    await box.close();
    console.info('close');
  }

  Future<void> clear() async {
    await box.clear();
    // refresh main listview
    await MainScreenController.to.load();
    await box.deleteFromDisk();
    console.info('clear');
  }

  Future<void> hidelete(Iterable<HiveLisoItem> items_) async {
    for (var e in items_) {
      e.deleted = true;
      await e.save();
    }
  }

  Future<void> import(List<HiveLisoItem> data, {Uint8List? cipherKey}) async {
    await open(cipherKey: cipherKey);
    box.addAll(data);
  }

  Future<File> export({required String path}) async {
    final jsonString = jsonEncode(data); // TODO: isolate
    final file = File(path);
    await file.writeAsString(jsonString);
    return await CipherService.to.encryptFile(file, addExtensionExtra: false);
  }

  Future<Either<dynamic, String>> obtainFieldValue(
      {required String itemId, required String fieldId}) async {
    final results = data.where((e) => e.identifier == itemId).toList();

    if (results.isEmpty) {
      return const Left('Field not found');
    }

    final field = results.first.fields.firstWhere(
      (e) => e.identifier == fieldId,
    );

    return Right(field.data.value!);
  }
}
