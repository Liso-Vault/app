import 'dart:async';

import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liso/core/services/wallet.service.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/ipfs/ipfs.service.dart';
import 'package:liso/firebase_options.dart';
import 'package:window_manager/window_manager.dart';

import 'core/firebase/config/config.service.dart';
import 'core/firebase/crashlytics.service.dart';
import 'core/hive/hive.manager.dart';
import 'core/liso/liso_paths.dart';
import 'core/notifications/notifications.manager.dart';
import 'core/services/persistence.service.dart';
import 'core/utils/biometric.util.dart';
import 'core/utils/utils.dart';
import 'features/app/app.dart';
import 'features/connectivity/connectivity.service.dart';
import 'features/s3/s3.service.dart';

void main() async {
  final console = Console(name: 'Main');

  // CAPTURE DART ERRORS
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // improve performance
    GestureBinding.instance.resamplingEnabled = true;

    if (isFirebaseSupported) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // initialize firebase and crashlytics before anything else to catch & report errors
    Get.put(CrashlyticsService());
    Get.put(ConfigService());

    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      await windowManager.ensureInitialized();
    }
    // init
    await LisoPaths.init();
    await HiveManager.init();
    await GetStorage.init();
    NotificationsManager.init();
    BiometricUtils.init();
    // GetX services
    Get.put(WalletService());
    Get.put(PersistenceService());
    Get.put(S3Service());
    Get.put(IPFSService());
    Get.put(ConnectivityService());
    Get.put(CipherService());
    // utils
    Utils.setDisplayMode(); // refresh rate
    await Utils.setWindowSize(); // for desktop
    // run main app
    runApp(const App());
  }, (Object exception, StackTrace stackTrace) {
    console.error("DART_ERROR");
    console.error('$exception');

    final details = FlutterErrorDetails(
      exception: exception,
      stack: stackTrace,
    );

    CrashlyticsService.recordStatic(details);
  });
}
