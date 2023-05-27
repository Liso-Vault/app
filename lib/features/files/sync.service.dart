import 'dart:convert';
import 'dart:typed_data';

import 'package:app_core/connectivity/connectivity.service.dart';

import 'package:app_core/persistence/persistence.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/features/files/storage.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';

import '../../core/hive/models/group.hive.dart';
import '../../core/hive/models/item.hive.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/liso/vault.model.dart';
import '../../core/utils/globals.dart';
import '../categories/categories.service.dart';
import '../groups/groups.service.dart';
import '../items/items.service.dart';
import '../shared_vaults/shared_vault.controller.dart';
import '../supabase/supabase_functions.service.dart';

const kDirBackups = 'Backups';
const kDirShared = 'Shared';
const kDirFiles = 'Files';

class SyncService extends GetxService with ConsoleMixin {
  static SyncService get to => Get.find();

  // VARIABLES
  // Minio? client;
  bool backedUp = false;

  final persistence = Get.find<Persistence>();
  final syncTimeoutDuration = 20.seconds;

  // PROPERTIES
  final syncing = false.obs;
  final syncingSharedVaults = false.obs;
  final inSync = false.obs;
  final progressValue = 0.05.obs;
  final progressText = 'Syncing...'.obs;

  // GETTERS

  bool get isReady =>
      ConnectivityService.to.connected.value && AppPersistence.to.sync.val;

  // INIT

  // FUNCTIONS

  Future<Either<dynamic, bool>> sync() async {
    if (!isReady) return const Right(false);

    if (syncing.value) {
      console.warning('already down syncing');
      return const Right(false);
    }

    console.info('syncing...');
    syncing.value = true;

    final statResult = await AppFunctionsService.to.statObject(
      kVaultFileName,
    );

    if (statResult.isLeft) {
      syncing.value = false;
      console.error('Stat Error: ${statResult.left}');
      return Left(statResult.left);
    }

    if (statResult.right.status != 200) {
      inSync.value = true;

      final upsyncResult = await upSync().timeout(
        syncTimeoutDuration,
        onTimeout: () => const Left('Timed Out'),
      );

      syncing.value = false;
      return upsyncResult;
    }

    final downResult = await _downSync().timeout(
      syncTimeoutDuration,
      onTimeout: () => const Left('Timed Out'),
    );

    // stop syncing indicator
    syncing.value = false;
    if (downResult.isLeft) return Left(downResult.left);
    // we are now ready to upSync because we are not in sync with server
    inSync.value = true;
    AppPersistence.to.changes.val = 0;
    // up sync local changes with server
    await upSync().timeout(
      syncTimeoutDuration,
      onTimeout: () => const Left('Timed Out'),
    );

    // reload all list
    MainScreenController.to.load();

    syncSharedVaults().timeout(
      syncTimeoutDuration,
      onTimeout: () => const Left('Timed Out'),
    );

    return Right(downResult.right);
  }

  // DOWN SYNC
  Future<Either<dynamic, bool>> _downSync() async {
    if (!isReady) return const Right(false);
    console.info('down syncing...');

    final result = await StorageService.to.download(
      object: kVaultFileName,
    );

    if (result.isLeft) return Left(result.left);
    final decryptedBytes = CipherService.to.decrypt(result.right);
    final jsonMap = jsonDecode(utf8.decode(decryptedBytes)); // TODO: isolate
    final vault = LisoVault.fromJson(jsonMap);
    await _mergeGroups(vault);
    await _mergeCategories(vault);
    await _mergeItems(vault);
    return const Right(true);
  }

  Future<void> backup(String object, Uint8List encryptedBytes) async {
    if (!isReady) return console.warning('offline');
    if (backedUp) {
      return console.warning('already backed up for todays session');
    }

    console.info('backup: $object...');

    // TODO: temporary
    // // REMOVE OLDEST BACKUP IF NECESSARY
    // if (StorageService.to.backups.length >= limits.backups) {
    //   final result = await StorageService.to.remove(
    //     StorageService.to.backups.first.key,
    //   );
    //   // abort backup if error in removing oldest backup
    //   if (result.isLeft) {
    //     return console.error('error removing last backup: ${result.left}');
    //   } else {
    //     console.wtf(
    //       'removed backup: ${result.right.data} - ${StorageService.to.backups.first.name}',
    //     );
    //   }
    // }

    // DO THE ACTUAL BACKUP
    final presignResult = await AppFunctionsService.to.presignUrl(
      object:
          '$kDirBackups/${DateTime.now().millisecondsSinceEpoch}-$kVaultFileName',
      method: 'PUT',
    );

    if (presignResult.isLeft || presignResult.right.status != 200) {
      return console.error('failed to presign');
    }

    // TODO: pass object metadata
    final response = await http.put(
      Uri.parse(presignResult.right.data.url),
      body: encryptedBytes,
    );

    console.info(
      'backup put response: ${response.statusCode} : ${response.body}',
    );

    backedUp = true;
  }

  // UP SYNC
  Future<Either<dynamic, bool>> upSync() async {
    if (!isReady) return const Left('offline');
    if (!inSync.value) {
      return const Left('not in sync with server');
    }

    console.info('up syncing...');

    // UPLOAD
    final vaultJsonString = await LisoManager.compactJson();

    final encryptedBytes = CipherService.to.encrypt(
      utf8.encode(vaultJsonString),
    );

    // BACKUP
    backup(kVaultFileName, encryptedBytes);

    final presignResult = await AppFunctionsService.to.presignUrl(
      object: kVaultFileName,
      method: 'PUT',
    );

    if (presignResult.isLeft || presignResult.right.status != 200) {
      return const Left('failed to presign');
    }

    console.info(
        'up sync data: ${encryptedBytes.length} -> ${presignResult.right.data.url}');

    // // TODO: pass object metadata
    // final response = await http.put(
    //   Uri.parse(presignResult.right.data.url),
    //   body: encryptedBytes,
    // );

    // console.info('up sync put response: ${response.statusCode}, ${response.body}');
    return const Right(true);
  }

  Future<Either<dynamic, bool>> syncSharedVaults() async {
    if (!isReady) return const Left('offline');

    if (SharedVaultsController.to.data.isEmpty) {
      return const Left('nothing to sync');
    }

    if (syncingSharedVaults.value) {
      return const Left('still syncing shared vaults');
    }

    console.info(
      'syncing ${SharedVaultsController.to.data.length} shared vaults...',
    );

    for (final sharedVault in SharedVaultsController.to.data) {
      final sharedItems = ItemsService.to.data
          .where((item) => item.sharedVaultIds.contains(sharedVault.docId))
          .toList();

      final cipherKeyResult = await ItemsService.to.obtainFieldValue(
        itemId: sharedVault.docId,
        fieldId: 'key',
      );

      if (cipherKeyResult.isLeft) {
        console.error('Cipher Key Not Found');
        return const Left('value');
      }

      final sharedItemsJson = List<dynamic>.from(
        sharedItems.map((x) => x.toJson()),
      );

      final sharedItemsJsonString = jsonEncode(sharedItemsJson);
      final bytes = Uint8List.fromList(utf8.encode(sharedItemsJsonString));

      final encryptedBytes = CipherService.to.encrypt(
        bytes,
        cipherKey: base64Decode(cipherKeyResult.right),
      );

      final presignResult = await AppFunctionsService.to.presignUrl(
        object: '$kDirShared/${sharedVault.docId}.$kVaultExtension',
        method: 'PUT',
      );

      if (presignResult.isLeft || presignResult.right.status != 200) {
        return const Left('failed to presign');
      }

      // TODO: pass object metadata
      final response = await http.put(
        Uri.parse(presignResult.right.data.url),
        body: encryptedBytes,
      );

      console.info('syncSharedVaults status: ${response.statusCode}');
    }

    console.wtf('done');
    return const Right(true);
  }

  Future<Either<dynamic, bool>> purge() async {
    if (!isReady) return const Left('offline');
    final result = await AppFunctionsService.to.deleteDirectory('');
    if (result.isLeft) return Left(result.left);
    return const Right(true);
  }

  // MERGING

  Future<void> _mergeGroups(LisoVault vault) async {
    final server = vault.groups;
    final local = GroupsService.to.box!;
    console
        .wtf('merged groups local: ${local.length}, server: ${server.length}');

    // merge server and local items
    final merged = [...server, ...local.values];
    // TODO: temporarily remove previously added groups
    merged.removeWhere((e) => e.isReserved);
    // sort all from most to least updated time
    merged.sort(
      (a, b) => b.metadata!.updatedTime.compareTo(a.metadata!.updatedTime),
    );

    // exclude permanently flagged deleted items
    final deletedIds =
        "${AppPersistence.to.deletedGroupIds},${vault.persistence['deleted-group-ids']}";
    merged.removeWhere((e) => deletedIds.contains(e.id));

    // leave only the most updated items
    final newList = <HiveLisoGroup>[];

    for (final item in merged) {
      final exists = newList.where((e) => e.id == item.id).isNotEmpty;
      if (exists) continue;
      newList.addIf(!newList.contains(item), item);
    }

    console.wtf('merged groups: ${newList.length}');
    await local.clear();
    await local.addAll(newList);
  }

  Future<void> _mergeCategories(LisoVault vault) async {
    final server = vault.categories ?? [];
    final local = CategoriesService.to.box!;
    console.wtf(
        'merged categories local: ${local.length}, server: ${server.length}');
    // merge server and local items
    final merged = [...server, ...local.values];
    // sort all from most to least updated time
    merged.sort(
      (a, b) => b.metadata!.updatedTime.compareTo(a.metadata!.updatedTime),
    );

    // exclude permanently flagged deleted items
    final deletedIds =
        "${AppPersistence.to.deletedCategoryIds},${vault.persistence['deleted-category-ids']}";
    merged.removeWhere((e) => deletedIds.contains(e.id));

    // leave only the most updated items
    final newList = <HiveLisoCategory>[];

    for (final item in merged) {
      final exists = newList.where((e) => e.id == item.id).isNotEmpty;
      if (exists) continue;
      newList.addIf(!newList.contains(item), item);
    }

    console.wtf('merged categories: ${newList.length}');
    await local.clear();
    await local.addAll(newList);
  }

  Future<void> _mergeItems(LisoVault vault) async {
    final server = vault.items;
    final local = ItemsService.to.box!;
    console.wtf(
      'merged items local: ${local.length}, server: ${server.length}',
    );

    // merge server and local items
    final merged = [...server, ...local.values];
    // sort all from most to least updated time
    merged.sort(
      (a, b) => b.metadata.updatedTime.compareTo(a.metadata.updatedTime),
    );

    // exclude permanently flagged deleted items
    final deletedIds =
        "${AppPersistence.to.deletedItemIds},${vault.persistence['deleted-item-ids']}";
    merged.removeWhere((e) => deletedIds.contains(e.identifier));
    // leave only the most updated items
    final newList = <HiveLisoItem>[];

    for (final item in merged) {
      final exists =
          newList.where((e) => e.identifier == item.identifier).isNotEmpty;
      if (exists) continue;
      newList.addIf(!newList.contains(item), item);
    }

    console.wtf('merged items: ${newList.length}');
    await local.clear();
    await local.addAll(newList);
  }
}
