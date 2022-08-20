import 'dart:async';

import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: library_prefixes
import 'package:firebase_dart/firebase_dart.dart' as firebaseDesktop;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/hive/hive.service.dart';
import 'package:liso/core/services/alchemy.service.dart';
import 'package:liso/features/autofill/autofill.service.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/groups/groups.service.dart';
import 'package:liso/features/pro/pro.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:secrets/firebase_options.dart';
import 'package:secrets/secrets.dart';
import 'package:window_manager/window_manager.dart';
import 'package:worker_manager/worker_manager.dart';

import 'core/firebase/analytics.service.dart';
import 'core/firebase/auth.service.dart';
import 'core/firebase/auth_desktop.service.dart';
import 'core/firebase/config/config.service.dart';
import 'core/firebase/crashlytics.service.dart';
import 'core/firebase/functions.service.dart';
import 'core/flavors/flavors.dart';
import 'core/liso/liso_paths.dart';
import 'core/notifications/notifications.manager.dart';
import 'core/persistence/persistence.dart';
import 'core/services/local_auth.service.dart';
import 'core/utils/utils.dart';
import 'features/app/app.dart';
import 'features/categories/categories.controller.dart';
import 'features/categories/categories.service.dart';
import 'features/connectivity/connectivity.service.dart';
import 'features/drawer/drawer_widget.controller.dart';
import 'features/groups/groups.controller.dart';
import 'features/items/items.controller.dart';
import 'features/items/items.service.dart';
import 'features/joined_vaults/joined_vault.controller.dart';
import 'features/main/main_screen.controller.dart';
import 'features/files/explorer/s3_content_tile.controller.dart';
import 'features/files/s3.service.dart';
import 'features/shared_vaults/shared_vault.controller.dart';

void init(Flavor flavor, {bool autofill = false}) async {
  Flavors.flavor = flavor;
  Globals.isAutofill = autofill;
  final console = Console(name: 'Main');
  console.wtf('Flavor: ${flavor.name}');

  // CAPTURE DART ERRORS
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // improve performance
    GestureBinding.instance.resamplingEnabled = true;
    // init firebase
    await Firebase.initializeApp(options: Secrets.firebaseOptions);

    if (GetPlatform.isWindows) {
      firebaseDesktop.FirebaseDart.setup();

      await firebaseDesktop.Firebase.initializeApp(
        options: firebaseDesktop.FirebaseOptions.fromMap(
          DefaultFirebaseOptions.currentPlatform.asMap,
        ),
      );
    } else {
      await FirebaseAppCheck.instance.activate();
    }
    // warm up executor
    await Executor().warmUp(
      log: true,
      isolatesCount: kDebugMode ? 2 : 50,
    );

    // GetX services
    Get.lazyPut(() => CrashlyticsService());
    Get.lazyPut(() => Persistence());
    Get.lazyPut(() => WalletService());
    Get.lazyPut(() => ConnectivityService());
    Get.lazyPut(() => CipherService());
    Get.lazyPut(() => LisoAutofillService());
    Get.lazyPut(() => FirestoreService());
    Get.lazyPut(() => FunctionsService());
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => AuthDesktopService());
    Get.lazyPut(() => AlchemyService());
    Get.lazyPut(() => S3Service());
    Get.lazyPut(() => ConfigService());
    Get.lazyPut(() => LocalAuthService());
    Get.lazyPut(() => HiveService());
    Get.lazyPut(() => ItemsService());
    Get.lazyPut(() => GroupsService());
    Get.lazyPut(() => CategoriesService());

    // permanent controllers
    Get.put(AnalyticsService());
    Get.put(ItemsController());
    Get.put(GroupsController());
    Get.put(CategoriesController());
    Get.put(DrawerMenuController());
    Get.put(MainScreenController());
    Get.put(SharedVaultsController());
    Get.put(JoinedVaultsController());
    Get.put(ProController());

    // create controllers
    Get.create(() => S3ContentTileController());

    // initializations
    CrashlyticsService.to.init();
    await Globals.init();
    await LisoPaths.init();
    await Persistence.open();
    HiveService.init();
    await ConfigService.to.init();
    await ProController.to.init();

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
