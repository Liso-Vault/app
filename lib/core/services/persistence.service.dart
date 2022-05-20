import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/translations/data.dart';
import 'package:path/path.dart';

import '../utils/globals.dart';

final persistencePath = join(LisoPaths.main!.path, 'get_storage');

class PersistenceService extends GetxService with ConsoleMixin {
  static PersistenceService get to => Get.find();

  // BOX
  final box = GetStorage();

  // WALLET
  final wallet = ''.val('wallet');
  // GENERAL
  final localeCode = 'en'.val('locale code');
  final crashReporting = true.val('crash reporting');
  final analytics = true.val('analytics');
  final proTester = true.val('pro tester');
  final lastBuildNumber = 0.val('last build number');
  final newEncryption = false.val('use new encryption');
  // WINDOW SIZE
  final windowWidth = 1200.0.val('window width');
  final windowHeight = 800.0.val('window height');
  // THEME
  final theme = ThemeMode.system.name.val('theme');
  // SECURITY
  final maxUnlockAttempts = 5.val('max unlock attempts');
  final timeLockDuration = 30.val('time lock duration'); // in seconds
  // NOTIFICATION
  final notificationId = 0.val('notification id');
  // SYNC
  final sync = true.val('sync');
  final syncConfirmed = false.val('sync confirmed');
  final syncProvider = LisoSyncProvider.sia.name.val('sync provider');
  final fileEncryption = false.val('file encryption');
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
  final groups = 'Personal,Work,Family,Other'.val('groups');
  final metadata = ''.val('vault metadata');
  final changes = 0.val('vault changes count');
  // PRICES
  final lastMaticBalance = 0.0.val('last matic balance');
  final lastLisoBalance = 0.0.val('last liso balance');
  final lastMaticUsdPrice = 0.0.val('last matic usd price');
  final lastLisoUsdPrice = 0.0.val('last liso usd price');

  // GETTERS

  // GetStorage get box => _box!;

  bool get canSync => sync.val && syncConfirmed.val;

  List<Map<String, dynamic>> get groupsMap => groups.val
      .split(',')
      .asMap()
      .entries
      .map((e) => {'index': e.key, 'name': e.value})
      .toList();

  // INIT
  @override
  void onInit() {
    _initLocale();
    super.onInit();
  }

  // FUNCTIONS

  void _initLocale() {
    final deviceLanguage = Get.deviceLocale?.languageCode;

    final isSystemLocaleSupported =
        translationKeys[deviceLanguage ?? 'en'] != null;
    final defaultLocaleCode = isSystemLocaleSupported ? deviceLanguage : 'en';

    box.writeIfNull('locale code', defaultLocaleCode);
  }
}
