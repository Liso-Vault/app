import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../liso/liso_paths.dart';
import '../utils/globals.dart';
import 'models/item.hive.dart';

class HiveItemsService extends GetxService with ConsoleMixin {
  static HiveItemsService get to => Get.find<HiveItemsService>();

  // VARIABLES
  late Box<HiveLisoItem> box;

  // GETTERS
  List<HiveLisoItem> get data => box.values.toList();

  bool get itemLimitReached => box.length >= WalletService.to.limits.items;

  bool get protectedItemLimitReached =>
      box.length >= WalletService.to.limits.items;

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
    await box.deleteFromDisk();
    console.info('reset');
  }

  Future<void> hidelete(Iterable<HiveLisoItem> items_) async {
    for (var e in items_) {
      e.deleted = true;
      await e.save();
    }
  }

  Future<File> export({required String path}) async {
    final jsonString = jsonEncode(data); // TODO: isolate
    final file = File(path);
    await file.writeAsString(jsonString);
    return await CipherService.to.encryptFile(file, addExtensionExtra: false);
  }

  Future<void> importVaultFile(File file, {Uint8List? cipherKey}) async {
    // parse vault to items
    final items_ = await parseVaultFile(file, cipherKey: cipherKey);
    await open(cipherKey: cipherKey!); // open database
    await box.addAll(items_); // populate database
  }

  Future<List<HiveLisoItem>> parseVaultFile(File file,
      {Uint8List? cipherKey}) async {
    final decryptedFile = await CipherService.to.decryptFile(
      file,
      cipherKey: cipherKey,
    );

    final jsonString = await decryptedFile.readAsString();
    final jsonMap = jsonDecode(jsonString); // TODO: isolate

    final importedItems = List<HiveLisoItem>.from(
      jsonMap.map((x) => HiveLisoItem.fromJson(x)),
    );

    return importedItems;
  }
}
