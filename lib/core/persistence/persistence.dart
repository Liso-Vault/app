import 'package:app_core/persistence/mutable_value.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../utils/globals.dart';

class AppPersistence extends Persistence with ConsoleMixin {
  // STATIC
  static AppPersistence get to => Get.find();
  static Box? box;

  // WALLET JSON
  final migratedSecrets = false.val('migrated-secrets');
  final wallet = ''.val('wallet');
  final walletPassword = ''.val('wallet-password');
  final walletSignature = ''.val('wallet-signature');
  final walletPrivateKeyHex = ''.val('wallet-private-key-hex');
  final walletAddress = ''.val('wallet-address');
  // GENERAL
  final backedUpSeed = false.val('backed-up-seed-phrase');
  final backedUpPassword = false.val('backed-up-password');
  final upgradeScreenShown = false.val('upgrade-screen-shown');
  // final rateCardVisibility = true.val('rate-card-visibility');
  // SYNC
  final sync = true.val('sync');
  final syncProvider = LisoSyncProvider.sia.name.val('sync-provider');
  final s3ObjectsCache = ''.val('s3-objects-cache');
  // // CUSTOM SYNC PROVIDER
  final s3Endpoint = ''.val('s3-endpoint');
  final s3AccessKey = ''.val('s3-access-key');
  final s3SecretKey = ''.val('s3-secret-key');
  final s3Bucket = ''.val('s3-bucket');
  final s3Port = ''.val('s3-port');
  final s3Region = ''.val('s3-region');
  final s3SessionToken = ''.val('s3-session-token');
  final s3UseSsl = true.val('s3 use-ssl');
  final s3EnableTrace = false.val('s3-enable-trace');
  // VAULT
  final changes = 0.val('vault-changes-count');
  final deletedGroupIds = ''.val('deleted-group-ids');
  final deletedCategoryIds = ''.val('deleted-category-ids');
  final deletedItemIds = ''.val('deleted-item-ids');
  // PRICES
  final lastMaticBalance = 0.0.val('last-matic-balance');
  final lastLisoBalance = 0.0.val('last-liso-balance');
  final lastMaticUsdPrice = 0.0.val('last-matic-usd-price');
  final lastLisoUsdPrice = 0.0.val('last-liso-usd-price');
  // DELETED IDS

  // GETTERS

  String get newSyncProvider => syncProvider.val == LisoSyncProvider.custom.name
      ? LisoSyncProvider.custom.name
      : LisoSyncProvider.sia.name;

  bool get canShare =>
      sync.val && AuthService.to.authenticated && !GetPlatform.isWindows;

  // INIT

  // FUNCTIONS
  void addToDeletedGroups(String id) {
    final ids = deletedGroupIds.val.split(',');
    ids.add(id);
    deletedGroupIds.val = ids.join(',');
    // console.wtf('deletedGroupIds: ${deletedGroupIds.val}');
  }

  void addToDeletedCategories(String id) {
    final ids = deletedCategoryIds.val.split(',');
    ids.add(id);
    deletedCategoryIds.val = ids.join(',');
    // console.wtf('deletedCategoryIds: ${deletedCategoryIds.val}');
  }

  void addToDeletedItems(String id) {
    final ids = deletedItemIds.val.split(',');
    ids.add(id);
    deletedItemIds.val = ids.join(',');
    // console.wtf('deletedItemIds');
  }

  // STATIC
}
