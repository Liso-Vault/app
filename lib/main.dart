import 'dart:async';

import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/services/alchemy.service.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:secrets/secrets.dart';
import 'package:window_manager/window_manager.dart';

import 'core/firebase/config/config.service.dart';
import 'core/firebase/crashlytics.service.dart';
import 'core/flavors/flavors.dart';
import 'core/hive/hive.manager.dart';
import 'core/liso/liso_paths.dart';
import 'core/notifications/notifications.manager.dart';
import 'core/persistence/persistence.dart';
import 'core/services/biometric.service.dart';
import 'core/utils/utils.dart';
import 'features/app/app.dart';
import 'features/connectivity/connectivity.service.dart';
import 'features/s3/s3.service.dart';

void init(Flavor flavor) async {
  Flavors.flavor = flavor;
  final console = Console(name: 'Main');

  // CAPTURE DART ERRORS
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // improve performance
    GestureBinding.instance.resamplingEnabled = true;
    // init firebase
    if (isFirebaseSupported) {
      await Firebase.initializeApp(options: Secrets.firebaseOptions);
    }

    // GetX services
    Get.lazyPut(() => CrashlyticsService());
    Get.lazyPut(() => Persistence());
    Get.lazyPut(() => WalletService());
    Get.lazyPut(() => ConnectivityService());
    Get.lazyPut(() => CipherService());
    Get.lazyPut(() => FirestoreService());
    Get.lazyPut(() => AlchemyService());
    Get.lazyPut(() => S3Service());
    Get.lazyPut(() => ConfigService());
    Get.lazyPut(() => BiometricService());

    CrashlyticsService.to.init();
    await LisoPaths.init();
    await Persistence.init();
    await ConfigService.to.init();

    // init
    HiveManager.init();
    NotificationsManager.init();
    Utils.setDisplayMode(); // refresh rate

    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      await windowManager.ensureInitialized();
      await Utils.setWindowSize(); // for desktop
    }

    runApp(const App()); // run
  }, (Object exception, StackTrace stackTrace) {
    console.error("DART_ERROR\n$exception");

    final details = FlutterErrorDetails(
      exception: exception,
      stack: stackTrace,
    );

    CrashlyticsService.recordStatic(details);
  });
}
