import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../persistence/persistence.dart';

class CrashlyticsService extends GetxService with ConsoleMixin {
  static CrashlyticsService get to => Get.find();

  // VARIABLES

  // GETTERS
  FirebaseCrashlytics get instance => FirebaseCrashlytics.instance;

  // INIT

  // FUNCTIONS

  void init() {
    // CAPTURE FLUTTER ERRORS
    FlutterError.onError = (details) {
      console.error("FLUTTER_ERROR");
      record(details.exception, details.stack);
    };

    // TODO: implement new crashlytics soon
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  void configure() {
    if (GetPlatform.isWindows) return console.warning('Not Supported');

    instance.setCrashlyticsCollectionEnabled(
      Persistence.to.crashReporting.val,
    );
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

    if (GetPlatform.isWindows) return console.warning('Not Supported');
    FirebaseCrashlytics.instance.recordFlutterError(details);
  }
}
