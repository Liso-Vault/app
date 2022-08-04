import 'dart:convert';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/persistence/mutable_value.dart';
import 'package:secrets/secrets.dart';

import '../liso/liso_paths.dart';
import '../translations/data.dart';
import '../utils/globals.dart';

class Persistence extends GetxController with ConsoleMixin {
  // STATIC
  static Persistence get to => Get.find();
  static Box? box;

  // WALLET JSON
  final wallet = ''.val('wallet');
  final walletPassword = ''.val('wallet-password');
  final walletSignature = ''.val('wallet-signature');
  final walletPrivateKeyHex = ''.val('wallet-private-key-hex');
  final walletAddress = ''.val('wallet-address');
  // GENERAL
  final localeCode = 'en'.val('locale-code');
  final crashReporting = true.val('crash-reporting');
  final analytics = true.val('analytics');
  final proTester = false.val('pro-tester');
  final lastBuildNumber = 0.val('last-build-number');
  final lastServerDateTime = ''.val('last-server-datetime');
  final backedUpSeed = false.val('backed-up-seed-phrase');
  final backedUpPassword = false.val('backed-up-password');
  // WINDOW SIZE
  final windowWidth = 1200.0.val('window-width');
  final windowHeight = 850.0.val('window-height');
  // THEME
  final theme = ThemeMode.system.name.val('theme');
  // SECURITY
  final maxUnlockAttempts = 10.val('max-unlock-attempts');
  final timeLockDuration = 120.val('time-lock-duration'); // in seconds
  // NOTIFICATION
  final notificationId = 0.val('notification-id');
  // SYNC
  final sync = true.val('sync');
  final syncProvider = LisoSyncProvider.sia.name.val('sync-provider');
  final biometrics = true.val('biometrics');
  final s3ObjectsCache = ''.val('s3-objects-cache');
  // CUSTOM SYNC PROVIDER
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

  // from the first 32 bits of the signature
  Uint8List get cipherKey =>
      Uint8List.fromList(utf8.encode(walletSignature.val).sublist(0, 32));

  bool get canShare =>
      sync.val && AuthService.to.isSignedIn && !GetPlatform.isWindows;

  String get shortAddress => walletAddress.val.isEmpty
      ? ''
      : '${walletAddress.val.substring(0, 11)}...${walletAddress.val.substring(walletAddress.val.length - 11)}';

  // FUNCTIONS
  static Future<void> open() async {
    box = await Hive.openBox(
      kHiveBoxPersistence,
      encryptionCipher: HiveAesCipher(base64Decode(Secrets.persistenceKey)),
      path: LisoPaths.hivePath,
    );

    _initLocale();
  }

  static Future<void> reset() async {
    await box?.clear();
    await box?.deleteFromDisk();
    await open();
  }

  static void _initLocale() {
    final deviceLanguage = Get.deviceLocale?.languageCode;

    final isSystemLocaleSupported =
        translationKeys[deviceLanguage ?? 'en'] != null;
    final defaultLocaleCode = isSystemLocaleSupported ? deviceLanguage : 'en';
    final localeCode = box?.get('locale code');

    if (defaultLocaleCode != null && localeCode == null) {
      box?.put('locale code', defaultLocaleCode);
    }
  }

  void addToDeletedGroups(String id) {
    final ids = deletedGroupIds.val.split(',');
    ids.add(id);
    deletedGroupIds.val = ids.join(',');
    console.wtf('deletedGroupIds: ${deletedGroupIds.val}');
  }

  void addToDeletedCategories(String id) {
    final ids = deletedCategoryIds.val.split(',');
    ids.add(id);
    deletedCategoryIds.val = ids.join(',');
    console.wtf('deletedCategoryIds: ${deletedCategoryIds.val}');
  }

  void addToDeletedItems(String id) {
    final ids = deletedItemIds.val.split(',');
    ids.add(id);
    deletedItemIds.val = ids.join(',');
    console.wtf('deletedItemIds: ${deletedItemIds.val}');
  }
}
