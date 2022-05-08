import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';

class CrashlyticsService extends GetxService with ConsoleMixin {
  static CrashlyticsService get to => Get.find();

  // VARIABLES

  // GETTERS

  // INIT
  @override
  void onInit() {
    _init();
    console.info('onInit');
    super.onInit();
  }

  // FUNCTIONS
  void _init() {
    if (isFirebaseSupported) {
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        // PersistenceService.to.crashReporting.val, // TODO: let user decide
        kReleaseMode,
      );
    }

    // CAPTURE FLUTTER ERRORS
    FlutterError.onError = (details) {
      console.error("FLUTTER_ERROR");
      record(details);
    };
  }

  void record(FlutterErrorDetails details) =>
      CrashlyticsService.recordStatic(details);

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
    final filteredErrors = [
      'Box may be corrupted', // wrong encryption key
    ];

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
