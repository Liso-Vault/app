import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liso/core/translations/data.dart';
import 'package:liso/core/utils/console.dart';

class PersistenceController extends GetxController with ConsoleMixin {
  static PersistenceController get to => Get.find();

  // BOX
  final box = GetStorage();

  // GENERAL
  final localeCode = 'en'.val('locale code');
  // WINDOW SIZE
  final windowSize = const Size(1200, 800).obs;
  // THEME
  final theme = ThemeMode.system.name.val('theme');
  // SECURITY
  final maxUnlockAttempts = 5.val('max unlock attempts');
  final timeLockDuration = 30.val('time lock duration'); // in seconds
  // NOTIFICATION
  final notificationId = 0.val('notification id');
  // WALLET
  final address = ''.val('wallet_address');

  // GETTERS

  @override
  void onInit() {
    _initLocale();
    super.onInit();
  }

  void _initLocale() {
    final isSystemLocaleSupported =
        translationKeys[Get.deviceLocale?.languageCode ?? 'en'] != null;
    final defaultLocaleCode =
        isSystemLocaleSupported ? Get.deviceLocale?.languageCode : 'en';

    box.writeIfNull('locale code', defaultLocaleCode);
  }
}
