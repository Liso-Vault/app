import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';

import '../../core/hive/models/group.hive.dart';
import '../../core/liso/liso_paths.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/utils/globals.dart';
import 'groups.controller.dart';

class GroupsService extends GetxService with ConsoleMixin {
  static GroupsService get to => Get.find<GroupsService>();

  // VARIABLES
  Box<HiveLisoGroup>? box;
  bool boxInitialized = false;

  // GETTERS
  List<HiveLisoGroup> get data =>
      box != null && box!.isOpen ? box!.values.toList() : [];

  // FUNCTIONS

  Future<void> open({Uint8List? cipherKey, bool initialize = true}) async {
    box = await Hive.openBox(
      kHiveBoxGroups,
      encryptionCipher:
          HiveAesCipher(cipherKey ?? SecretPersistence.to.cipherKey),
      path: LisoPaths.hivePath,
    );

    _migrate();
    boxInitialized = true;
  }

  void _migrate() async {
    // TODO: temporarily remove previously added groups
    final groupsToDelete = data.where((e) => e.isReserved).map((e) => e.key);
    await box?.deleteAll(groupsToDelete);
    console.info('length: ${data.length}');
    GroupsController.to.load();
  }

  Future<void> close() async {
    await box?.close();
    console.info('close');
  }

  Future<void> clear() async {
    if (box?.isOpen == false) return;

    if (!boxInitialized) {
      await File(join(LisoPaths.hivePath, '$kHiveBoxGroups.hive')).delete();
      return;
    }

    await box?.clear();
    // refresh cusom vaults
    GroupsController.to.load();
    await box?.deleteFromDisk();
    console.info('clear');
  }

  Future<void> import(List<HiveLisoGroup> data, {Uint8List? cipherKey}) async {
    await open(cipherKey: cipherKey, initialize: false);
    await box?.clear();
    box?.addAll(data);
  }
}
