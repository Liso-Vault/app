import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:path/path.dart';

import '../../core/hive/models/item.hive.dart';
import '../../core/liso/liso_paths.dart';
import '../../core/persistence/persistence.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/utils/globals.dart';

class ItemsService extends GetxService with ConsoleMixin {
  static ItemsService get to => Get.find<ItemsService>();

  // VARIABLES
  Box<HiveLisoItem>? box;
  bool boxInitialized = false;

  // GETTERS
  List<HiveLisoItem> get data =>
      box != null && box!.isOpen ? box!.values.toList() : [];

  // FUNCTIONS

  Future<void> open({Uint8List? cipherKey}) async {
    box = await Hive.openBox(
      kHiveBoxItems,
      encryptionCipher:
          HiveAesCipher(cipherKey ?? SecretPersistence.to.cipherKey),
      path: LisoPaths.hivePath,
    );

    boxInitialized = true;
    console.info('length: ${data.length}');
  }

  Future<void> close() async {
    await box?.close();
    console.info('close');
  }

  Future<void> clear() async {
    if (!boxInitialized) {
      await File(join(LisoPaths.hivePath, '$kHiveBoxItems.hive')).delete();
      return;
    }

    await box?.clear();
    // refresh main listview
    await ItemsController.to.load();
    await box?.deleteFromDisk();
    console.info('clear');
  }

  Future<void> hideleteItems(Iterable<HiveLisoItem> items_) async {
    for (var e in items_) {
      e.deleted = true;
      await e.save();
    }
  }

  Future<void> deleteItems(Iterable<HiveLisoItem> items_) async {
    for (var e in items_) {
      Persistence.to.addToDeletedItems(e.identifier);
      await e.delete();
    }
  }

  Future<void> moveToGroup(
    Iterable<HiveLisoItem> items_,
    String groupId,
  ) async {
    for (var e in items_) {
      e.groupId = groupId;
      await e.save();
    }
  }

  Future<void> import(List<HiveLisoItem> data, {Uint8List? cipherKey}) async {
    await open(cipherKey: cipherKey);
    await box?.clear();
    box?.addAll(data);
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
