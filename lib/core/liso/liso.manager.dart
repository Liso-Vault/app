import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_core/persistence/persistence.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/core/liso/vault.model.dart';
import 'package:liso/features/categories/categories.service.dart';
import 'package:path/path.dart';

import '../../features/groups/groups.service.dart';
import '../../features/items/items.service.dart';
import '../hive/models/metadata/metadata.hive.dart';
import '../services/cipher.service.dart';
import '../utils/globals.dart';
import 'liso_paths.dart';

class LisoManager {
  // VARIABLES
  static final console = Console(name: 'LisoManager');

  // GETTERS

  // FUNCTIONS

  static Future<String> compactJson() async {
    final persistenceMap = Persistence.box!.toMap();
    // exclude sensitive data
    // TODO:xxx transfer this to the new secret persistence
    persistenceMap.remove('wallet-password');
    persistenceMap.remove('wallet-signature');
    persistenceMap.remove('wallet-private-key-hex');

    final vault = LisoVault(
      groups: GroupsService.to.data,
      categories: CategoriesService.to.data,
      items: ItemsService.to.data,
      persistence: persistenceMap,
      version: kVaultFormatVersion,
      metadata: await HiveMetadata.get(),
    );

    return vault.toJsonString();
  }

  static Future<void> importVault(LisoVault vault,
      {Uint8List? cipherKey}) async {
    await GroupsService.to.import(vault.groups, cipherKey: cipherKey);
    await CategoriesService.to.import(vault.categories!, cipherKey: cipherKey);
    await ItemsService.to.import(vault.items, cipherKey: cipherKey);
  }

  static Future<LisoVault> parseVaultBytes(
    Uint8List bytes, {
    Uint8List? cipherKey,
  }) async {
    // console.wtf('decrypt parseVaultBytes()');
    final decryptedBytes = CipherService.to.decrypt(
      bytes,
      cipherKey: cipherKey,
    );

    final jsonString = utf8.decode(decryptedBytes);
    final jsonMap = jsonDecode(jsonString); // TODO: isolate
    return LisoVault.fromJson(jsonMap);
  }

  static Future<void> createBackup() async {
    // make a temporary local backup
    final encryptedBytes = CipherService.to.encrypt(
      utf8.encode(await compactJson()),
    );

    final backupFile = File(join(
      LisoPaths.tempPath,
      'backup.$kVaultExtension',
    ));

    final encryptedBackupFile = await backupFile.writeAsBytes(encryptedBytes);
    console.info('backup created: ${encryptedBackupFile.path}');
  }
}
