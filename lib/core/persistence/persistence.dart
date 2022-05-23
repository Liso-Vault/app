import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/persistence/mutable_value.dart';
import 'package:liso/core/utils/secrets.dart';

import '../liso/liso_paths.dart';
import '../translations/data.dart';
import '../utils/globals.dart';

class Persistence extends GetxController with ConsoleMixin {
  // STATIC
  static Persistence get to => Get.find();
  static late Box box;

  // VARIABLES
  final test = 'default'.val('test');
  // WALLET JSON
  final wallet = ''.val('wallet');
  // GENERAL
  final localeCode = 'en'.val('locale code');
  final crashReporting = true.val('crash reporting');
  final analytics = true.val('analytics');
  final proTester = true.val('pro tester');
  final lastBuildNumber = 0.val('last build number');
  // WINDOW SIZE
  final windowWidth = 1200.0.val('window width');
  final windowHeight = 850.0.val('window height');
  // THEME
  final theme = ThemeMode.system.name.val('theme');
  // SECURITY
  final maxUnlockAttempts = 5.val('max unlock attempts');
  final timeLockDuration = 120.val('time lock duration'); // in seconds
  // NOTIFICATION
  final notificationId = 0.val('notification id');
  // SYNC
  final sync = true.val('sync');
  final syncConfirmed = false.val('sync confirmed');
  final syncProvider = LisoSyncProvider.sia.name.val('sync provider');
  final fileEncryption = false.val('file encryption');
  final s3ObjectsCache = ''.val('s3 objects cache');
  // CUSTOM SYNC PROVIDER
  final s3Endpoint = ''.val('s3 endpoint');
  final s3AccessKey = ''.val('s3 access key');
  final s3SecretKey = ''.val('s3 secret key');
  final s3Bucket = ''.val('s3 bucket');
  final s3Port = ''.val('s3 port');
  final s3Region = ''.val('s3 region');
  final s3SessionToken = ''.val('s3 session token');
  final s3UseSsl = true.val('s3 use ssl');
  final s3EnableTrace = false.val('s3 enable trace');
  // VAULT
  final groupIndex = 0.val('group index');
  final groups = 'Personal,Shared,Work,Family,Other'.val('groups');
  final metadata = ''.val('vault metadata');
  final changes = 0.val('vault changes count');
  // PRICES
  final lastMaticBalance = 0.0.val('last matic balance');
  final lastLisoBalance = 0.0.val('last liso balance');
  final lastMaticUsdPrice = 0.0.val('last matic usd price');
  final lastLisoUsdPrice = 0.0.val('last liso usd price');

  // GETTERS

  bool get canSync => sync.val && syncConfirmed.val;

  List<Map<String, dynamic>> get groupsMap => groups.val
      .split(',')
      .asMap()
      .entries
      .map((e) => {'index': e.key, 'name': e.value})
      .toList();

  // FUNCTIONS
  static Future<void> init() async {
    box = await Hive.openBox(
      kHivePersistence,
      encryptionCipher: HiveAesCipher(base64Decode(kHivePersistenceCipherKey)),
      path: LisoPaths.hivePath,
    );

    _initLocale();
  }

  static Future<void> reset() async {
    await box.deleteFromDisk();
    await init();
  }

  static void _initLocale() {
    final deviceLanguage = Get.deviceLocale?.languageCode;

    final isSystemLocaleSupported =
        translationKeys[deviceLanguage ?? 'en'] != null;
    final defaultLocaleCode = isSystemLocaleSupported ? deviceLanguage : 'en';
    final localeCode = box.get('locale code');

    if (defaultLocaleCode != null && localeCode == null) {
      box.put('locale code', defaultLocaleCode);
    }
  }
}