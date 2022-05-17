import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/translations/data.dart';
import 'package:path/path.dart';

class PersistenceService extends GetxService with ConsoleMixin {
  static PersistenceService get to => Get.find();

  // BOX
  final box = GetPlatform.isWeb
      ? GetStorage('persistence')
      : GetStorage(
          'persistence',
          join(LisoPaths.main!.path, 'get_storage'),
        );

  // WALLET
  final wallet = ''.val('wallet');
  // GENERAL
  final localeCode = 'en'.val('locale code');
  final crashReporting = true.val('crash reporting');
  final analytics = true.val('analytics');
  final proTester = true.val('pro tester');
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
  // IPFS
  final ipfsSync = false.val('ipfs sync');
  final ipfsInstantSync = false.val('ipfs instant sync');
  final ipfsScheme = 'http'.val('ipfs scheme');
  final ipfsHost = '127.0.0.1'.val('ipfs host');
  final ipfsPort = 5001.val('ipfs port');
  final ipfsLocalStat = ''.val('ipfs local vault stat');
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

  bool get canSync => sync.val && syncConfirmed.val;

  String get ipfsServerUrl =>
      '${ipfsScheme.val}://${ipfsHost.val}:${ipfsPort.val}';

  List<Map<String, dynamic>> get groupsMap => groups.val
      .split(',')
      .asMap()
      .entries
      .map((e) => {'index': e.key, 'name': e.value})
      .toList();

  @override
  void onInit() {
    _initLocale();
    super.onInit();
  }

  void _initLocale() {
    final deviceLanguage = Get.deviceLocale?.languageCode;

    final isSystemLocaleSupported =
        translationKeys[deviceLanguage ?? 'en'] != null;
    final defaultLocaleCode = isSystemLocaleSupported ? deviceLanguage : 'en';

    box.writeIfNull('locale code', defaultLocaleCode);
  }
}
