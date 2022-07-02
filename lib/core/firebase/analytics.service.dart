import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import 'auth.service.dart';

class AnalyticsService extends GetxService with ConsoleMixin {
  static AnalyticsService get to => Get.find();

  // VARIABLES
  final observer = FirebaseAnalyticsObserver(
    analytics: FirebaseAnalytics.instance,
  );

  // PROPERTIES

  // GETTERS
  FirebaseAnalytics get instance => FirebaseAnalytics.instance;

  // INIT
  @override
  void onInit() async {
    if (GetPlatform.isWindows) {
      return;
    }

    await instance.setAnalyticsCollectionEnabled(Persistence.to.analytics.val);
    await instance.logAppOpen();
    super.onInit();
  }

  // FUNCTIONS
  void init() async {
    await instance.setUserId(id: AuthService.to.userId);

    await instance.setUserProperty(
      name: 'wallet-address',
      value: WalletService.to.longAddress,
    );
  }

  void logSignIn() async {
    if (GetPlatform.isWindows) {
      return;
    }

    await instance.logLogin();
  }

  void logSignOut() async {
    if (GetPlatform.isWindows) {
      return;
    }

    await instance.logEvent(name: 'logout');
  }
}
