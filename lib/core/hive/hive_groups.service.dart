import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:path/path.dart';
import 'package:secrets/secrets.dart';

import '../../features/groups/groups.controller.dart';
import '../liso/liso_paths.dart';
import '../utils/globals.dart';
import 'models/group.hive.dart';

class HiveGroupsService extends GetxService with ConsoleMixin {
  static HiveGroupsService get to => Get.find<HiveGroupsService>();

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
      encryptionCipher: HiveAesCipher(cipherKey ?? WalletService.to.cipherKey!),
      path: LisoPaths.hivePath,
    );

    boxInitialized = true;

    if (box!.isEmpty && initialize) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    // initial groups
    final groups = List<HiveLisoGroup>.from(
      Secrets.groups.map((x) => HiveLisoGroup.fromJson(x)),
    );

    await box!.addAll(groups);
  }

  Future<void> close() async {
    await box!.close();
    console.info('close');
  }

  Future<void> clear() async {
    if (!boxInitialized) {
      await File(join(LisoPaths.hivePath, '$kHiveBoxGroups.hive')).delete();
      return;
    }

    await box!.clear();
    // refresh cusom vaults
    GroupsController.to.load();
    await box!.deleteFromDisk();
    console.info('clear');
  }

  Future<void> import(List<HiveLisoGroup> data, {Uint8List? cipherKey}) async {
    await open(cipherKey: cipherKey, initialize: false);
    box!.addAll(data);
  }

  Future<void> purge() async {
    await box!.clear();
    await _initialize();
  }
}
