import 'dart:async';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:secrets/secrets.dart';

import '../liso/liso_paths.dart';
import '../utils/globals.dart';
import 'models/group.hive.dart';

class HiveGroupsService extends GetxService with ConsoleMixin {
  static HiveGroupsService get to => Get.find<HiveGroupsService>();

  // VARIABLES
  late Box<HiveLisoGroup> box;

  // GETTERS
  List<HiveLisoGroup> get data => box.values.toList();

  // FUNCTIONS

  Future<void> open({Uint8List? cipherKey}) async {
    box = await Hive.openBox(
      kHiveBoxGroups,
      encryptionCipher: HiveAesCipher(cipherKey ?? WalletService.to.cipherKey!),
      path: LisoPaths.hivePath,
    );

    if (box.isEmpty) {
      // initial groups
      final groups = List<HiveLisoGroup>.from(
        Secrets.groups.map((x) => HiveLisoGroup.fromJson(x)),
      );

      await box.addAll(groups);
      console.info('added initial groups');
    }
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
