import 'dart:async';

import 'package:desktop_window/desktop_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/ipfs/ipfs.service.dart';

import 'core/firebase/config/config.service.dart';
import 'core/firebase/crashlytics.service.dart';
import 'core/hive/hive.manager.dart';
import 'core/liso/liso_paths.dart';
import 'core/notifications/notifications.manager.dart';
import 'core/services/authentication.service.dart';
import 'core/services/persistence.service.dart';
import 'core/utils/biometric.util.dart';
import 'core/utils/console.dart';
import 'features/app/app.dart';
import 'features/s3/s3.service.dart';

void main() async {
  final console = Console(name: 'Main');

  // CAPTURE DART ERRORS
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // improve performance
    GestureBinding.instance?.resamplingEnabled = true;
    // init Firebase
    await Firebase.initializeApp();
    // init Liso paths
    await LisoPaths.init();
    // init Hive
    await HiveManager.init();
    // init GetStorage
    await GetStorage.init();
    // init NotificationManager
    NotificationsManager.init();
    // init Biometric Utils
    BiometricUtils.init();

    Get.put(CrashlyticsService());
    Get.put(ConfigService());
    Get.put(PersistenceService());
    Get.put(S3Service());
    Get.put(AuthenticationService());
    Get.put(IPFSService());

    // setup window size for desktop
    _setupWindowSize();
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

void _setupWindowSize() async {
  if (!GetPlatform.isDesktop || GetPlatform.isWeb) return;
  await DesktopWindow.setWindowSize(PersistenceService.to.windowSize());
  await DesktopWindow.setMinWindowSize(kMinWindowSize);
}
