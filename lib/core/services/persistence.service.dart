import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/translations/data.dart';
import 'package:path/path.dart';

import '../utils/globals.dart';

GetStorage box() => PersistenceService.box_!;

class PersistenceService extends GetxService with ConsoleMixin {
  static PersistenceService get to => Get.find();

  static GetStorage? box_;

  static Future<void> init() async {
    const container = 'persistence';
    final path = join(LisoPaths.main!.path, 'get_storage');

    box_ = GetStorage(container, path);
    await box_!.initStorage;
  }

  static Future<void> reset() async {
    await box_!.erase();
  }

  // TODO: use secure storage
  final wallet = ''.val('wallet', getBox: box);
  final s3AccessKey = ''.val('s3 access key', getBox: box);
  final s3SecretKey = ''.val('s3 secret key', getBox: box);

  // GENERAL
  final localeCode = 'en'.val('locale code', getBox: box);
  final crashReporting = true.val('crash reporting', getBox: box);
  final analytics = true.val('analytics', getBox: box);
  final proTester = true.val('pro tester', getBox: box);
  final lastBuildNumber = 0.val('last build number', getBox: box);
  // WINDOW SIZE
  final windowWidth = 1200.0.val('window width', getBox: box);
  final windowHeight = 850.0.val('window height', getBox: box);
  // THEME
  final theme = ThemeMode.system.name.val('theme', getBox: box);
  // SECURITY
  final maxUnlockAttempts = 5.val('max unlock attempts', getBox: box);
  final timeLockDuration =
      120.val('time lock duration', getBox: box); // in seconds
  // NOTIFICATION
  final notificationId = 0.val('notification id', getBox: box);
  // SYNC
  final sync = true.val('sync', getBox: box);
  final syncConfirmed = false.val('sync confirmed', getBox: box);
  final syncProvider =
      LisoSyncProvider.sia.name.val('sync provider', getBox: box);
  final fileEncryption = false.val('file encryption', getBox: box);
  final s3ObjectsCache = ''.val('s3 objects cache', getBox: box);
  // CUSTOM SYNC PROVIDER
  final s3Endpoint = ''.val('s3 endpoint', getBox: box);
  final s3Bucket = ''.val('s3 bucket', getBox: box);
  final s3Port = ''.val('s3 port', getBox: box);
  final s3Region = ''.val('s3 region', getBox: box);
  final s3SessionToken = ''.val('s3 session token', getBox: box);
  final s3UseSsl = true.val('s3 use ssl', getBox: box);
  final s3EnableTrace = false.val('s3 enable trace', getBox: box);
  // VAULT
  final groupIndex = 0.val('group index', getBox: box);
  final groups = 'Personal,Work,Family,Other'.val('groups', getBox: box);
  final metadata = ''.val('vault metadata', getBox: box);
  final changes = 0.val('vault changes count', getBox: box);
  // PRICES
  final lastMaticBalance = 0.0.val('last matic balance', getBox: box);
  final lastLisoBalance = 0.0.val('last liso balance', getBox: box);
  final lastMaticUsdPrice = 0.0.val('last matic usd price', getBox: box);
  final lastLisoUsdPrice = 0.0.val('last liso usd price', getBox: box);

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

    box().writeIfNull('locale code', defaultLocaleCode);
  }
}
