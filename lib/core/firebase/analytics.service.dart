import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:liso/core/persistence/persistence.dart';

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
