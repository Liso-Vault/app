import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:liso/core/utils/globals.dart';

import '../persistence/persistence.dart';

class CrashlyticsService extends GetxService with ConsoleMixin {
  static CrashlyticsService get to => Get.find();

  // VARIABLES

  // GETTERS

  // INIT

  // FUNCTIONS

  void init() {
    // CAPTURE FLUTTER ERRORS
    FlutterError.onError = (details) {
      console.error("FLUTTER_ERROR");
      record(details.exception, details.stack);
    };
  }

  void configure() {
    if (!isFirebaseSupported) return console.warning('Not Supported');

    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      Persistence.to.crashReporting.val,
    );

    FirebaseCrashlytics.instance
        .setUserIdentifier(WalletService.to.longAddress);
  }

  void record(Object e, StackTrace? s, {bool fatal = false}) {
    return CrashlyticsService.recordStatic(FlutterErrorDetails(
      exception: e,
      stack: s,
    ));
  }

  static void recordStatic(FlutterErrorDetails details) {
    final console = Console(name: 'CrashlyticsService');
    final errorString = details.summary.value.toString();

    if (kDebugMode) {
      console.error('DEBUG ERROR: $errorString');
      return FlutterError.dumpErrorToConsole(
        details,
        forceReport: true,
      );
    }

    // filtered errors
    final filteredErrors = [];

    // filter unnecessary error reports
    for (var e in filteredErrors) {
      if (errorString.contains(e)) {
        return console.error('FILTERED: $errorString');
      }
    }

    if (!isFirebaseSupported) return console.warning('Not Supported');
    FirebaseCrashlytics.instance.recordFlutterError(details);
  }
}
