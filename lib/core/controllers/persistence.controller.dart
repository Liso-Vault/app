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
  // FONT
  final fontName = 'Roboto'.val('font name');
  final fontScaleFactor = 1.0.val('font scale factor');
  // THEME
  final darkMode = true.val('dark mode');
  // APP LOCK
  final appLock = false.val('app lock');
  final appLockCode = ''.val('app lock code');
  final maxUnlockAttempts = 5.val('max unlock attempts');
  // NOTIFICATION
  final notificationId = 0.val('notification id');

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
