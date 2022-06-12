import 'dart:async';

import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/hive/hive.service.dart';
import 'package:liso/core/hive/hive_groups.service.dart';
import 'package:liso/core/services/alchemy.service.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:secrets/secrets.dart';
import 'package:window_manager/window_manager.dart';

import 'core/firebase/auth.service.dart';
import 'core/firebase/config/config.service.dart';
import 'core/firebase/crashlytics.service.dart';
import 'core/flavors/flavors.dart';
import 'core/hive/hive_items.service.dart';
import 'core/liso/liso_paths.dart';
import 'core/notifications/notifications.manager.dart';
import 'core/persistence/persistence.dart';
import 'core/services/local_auth.service.dart';
import 'core/utils/utils.dart';
import 'features/app/app.dart';
import 'features/connectivity/connectivity.service.dart';
import 'features/joined_vaults/joined_vault.controller.dart';
import 'features/s3/s3.service.dart';
import 'features/shared_vaults/shared_vault.controller.dart';

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
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => AlchemyService());
    Get.lazyPut(() => S3Service());
    Get.lazyPut(() => ConfigService());
    Get.lazyPut(() => LocalAuthService());
    Get.lazyPut(() => HiveService());
    Get.lazyPut(() => HiveItemsService());
    Get.lazyPut(() => HiveGroupsService());

    Get.put(SharedVaultsController());
    Get.put(JoinedVaultsController());

    CrashlyticsService.to.init();
    await Globals.init();
    await LisoPaths.init();
    await Persistence.open();
    HiveService.init();
    await ConfigService.to.init();

    // init
    NotificationsManager.init();
    Utils.setDisplayMode(); // refresh rate

    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      await windowManager.ensureInitialized();
      await Utils.setWindowSize(); // for desktop
    }

    LicenseRegistry.addLicense(() async* {
      final license = await rootBundle.loadString('google_fonts/OFL.txt');
      yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    });

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
