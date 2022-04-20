import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ipfs_rpc/ipfs_rpc.dart';
import 'package:liso/core/translations/data.dart';
import 'package:liso/core/utils/console.dart';

import '../liso/liso.manager.dart';

class PersistenceService extends GetxService with ConsoleMixin {
  static PersistenceService get to => Get.find();

  // BOX
  final box = GetStorage();

  // GENERAL
  final localeCode = 'en'.val('locale code');
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
  final sync = false.val('sync');
  final syncConfirmed = false.val('sync confirmed');
  // IPFS
  final ipfsSync = false.val('ipfs sync');
  final ipfsInstantSync = false.val('ipfs instant sync');
  final ipfsScheme = 'http'.val('ipfs scheme');
  final ipfsHost = '127.0.0.1'.val('ipfs host');
  final ipfsPort = 5001.val('ipfs port');
  final ipfsLocalStat = ''.val('ipfs local vault stat');
  // FILEBASE
  final s3LastModified = DateTime.now().val('s3 last modified');
  // VAULT
  final metadata = ''.val('vault metadata');
  final changes = 0.val('vault changes count');
  // final walletAddress = ''.val('wallet address');

  // GETTERS

  bool get canSync =>
      sync.val && syncConfirmed.val && LisoManager.walletAddress.isNotEmpty;

  String get ipfsServerUrl =>
      '${ipfsScheme.val}://${ipfsHost.val}:${ipfsPort.val}';

  FilesStatResponse? get localStat {
    dynamic jsonObject;

    try {
      jsonObject = jsonDecode(ipfsLocalStat.val);
    } catch (e) {
      return null;
    }

    return FilesStatResponse.fromJson(jsonObject);
  }

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
