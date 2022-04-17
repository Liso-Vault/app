import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liso/features/ipfs/ipfs.service.dart';
import 'package:window_manager/window_manager.dart';

import 'core/firebase/config/config.service.dart';
import 'core/firebase/crashlytics.service.dart';
import 'core/hive/hive.manager.dart';
import 'core/liso/liso_paths.dart';
import 'core/notifications/notifications.manager.dart';
import 'core/services/authentication.service.dart';
import 'core/services/persistence.service.dart';
import 'core/utils/biometric.util.dart';
import 'core/utils/console.dart';
import 'core/utils/utils.dart';
import 'features/app/app.dart';
import 'features/s3/s3.service.dart';

void main() async {
  final console = Console(name: 'Main');

  // CAPTURE DART ERRORS
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // improve performance
    GestureBinding.instance?.resamplingEnabled = true;
    // initialize firebase and crashlytics before anything else to catch & report errors
    await Firebase.initializeApp();
    Get.put(CrashlyticsService());

    if (GetPlatform.isDesktop) {
      await windowManager.ensureInitialized();
    }
    // init
    await LisoPaths.init();
    await HiveManager.init();
    await GetStorage.init();
    NotificationsManager.init();
    BiometricUtils.init();
    // GetX services
    Get.put(ConfigService());
    Get.put(PersistenceService());
    Get.put(S3Service());
    Get.put(AuthenticationService());
    Get.put(IPFSService());
    // utils
    Utils.setDisplayMode(); // refresh rate
    await Utils.setWindowSize(); // for desktop
    // run main app
    runApp(const App());
  }, (Object exception, StackTrace stackTrace) {
    console.error("DART_ERROR");

    final details = FlutterErrorDetails(
      exception: exception,
      stack: stackTrace,
    );

    CrashlyticsService.to.record(details);
  });
}
