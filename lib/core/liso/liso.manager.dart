import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/hive/hive.service.dart';
import 'package:liso/features/categories/categories.service.dart';
import 'package:liso/core/liso/vault.model.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/drawer/drawer_widget.controller.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../features/groups/groups.service.dart';
import '../../features/item/items.service.dart';
import '../hive/models/metadata/metadata.hive.dart';
import '../services/cipher.service.dart';
import '../utils/globals.dart';

class LisoManager {
  // VARIABLES
  static final console = Console(name: 'LisoManager');

  // GETTERS

  // FUNCTIONS

  static Future<void> reset() async {
    console.info('resetting...');
    // clear filters
    DrawerMenuController.to.clearFilters();
    // reset persistence
    await Persistence.reset();
    // reset s3 minio client
    S3Service.to.init();
    // reset wallet
    WalletService.to.reset();
    // delete FilePicker caches
    if (GetPlatform.isMobile) {
      await FilePicker.platform.clearTemporaryFiles();
    }
    // reset firebase
    await AuthService.to.signOut();
    // clear hives
    await HiveService.to.clear();
    console.info('reset!');
  }

  static Future<String> compactJson() async {
    final vault = LisoVault(
      groups: GroupsService.to.data,
      categories: CategoriesService.to.data,
      items: ItemsService.to.data,
      persistence: Persistence.box.toMap(),
      version: kVaultFormatVersion,
      metadata: await HiveMetadata.get(),
    );

    return vault.toJsonString();
  }

  static Future<void> importVaultFile(File file, {Uint8List? cipherKey}) async {
    // parse vault to items
    final vault = await parseVaultFile(file, cipherKey: cipherKey);
    await GroupsService.to.import(vault.groups, cipherKey: cipherKey);
    await ItemsService.to.import(vault.items, cipherKey: cipherKey);
  }

  static Future<LisoVault> parseVaultFile(
    File file, {
    Uint8List? cipherKey,
  }) async {
    final decryptedFile = await CipherService.to.decryptFile(
      file,
      cipherKey: cipherKey,
    );

    final jsonString = await decryptedFile.readAsString();
    final jsonMap = jsonDecode(jsonString); // TODO: isolate
    return LisoVault.fromJson(jsonMap);
  }
}
