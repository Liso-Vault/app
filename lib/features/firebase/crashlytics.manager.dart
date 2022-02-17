import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:liso/core/utils/console.dart';

class CrashlyticsManager {
  static final console = Console(name: 'CrashlyticsManager');

  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT
  static void init() {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      kReleaseMode,
    );

    // CAPTURE FLUTTER ERRORS
    FlutterError.onError = (details) {
      console.error("FLUTTER_ERROR");
      record(details);
    };
  }

  // FUNCTIONS
  static void record(FlutterErrorDetails details) {
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
    if (filteredErrors.contains(errorString)) {
      return console.error('FILTERED: $errorString');
    }

    FirebaseCrashlytics.instance.recordFlutterError(details);
  }
}
