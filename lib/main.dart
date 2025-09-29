import 'dart:async';

import 'package:app_core/config.dart';
import 'package:app_core/config/secrets.model.dart';
import 'package:app_core/firebase/crashlytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/upgrade/upgrade_config.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:core_client/core_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive.service.dart';
import 'package:liso/core/persistence/persistence.secret.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/features/autofill/autofill.service.dart';
import 'package:liso/features/config/config.dart';
import 'package:liso/features/groups/groups.service.dart';
import 'package:liso/features/supabase/supabase_functions.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:liso/firebase_options.dart';
import 'package:liso/resources/resources.dart';
import 'package:secrets/secrets.dart';
import 'package:worker_manager/worker_manager.dart';

import 'core/flavors/flavors.dart';
import 'core/liso/liso_paths.dart';
import 'core/persistence/persistence.dart';
import 'core/services/app.service.dart';
import 'core/services/global.service.dart';
import 'core/translations/data.dart';
import 'core/utils/globals.dart';
import 'core/utils/utils.dart';
import 'features/app/app.dart';
import 'features/app/pages.dart';
import 'features/categories/categories.controller.dart';
import 'features/categories/categories.service.dart';
import 'features/config/pricing.dart';
import 'features/config/secrets.dart';
import 'features/drawer/drawer_widget.controller.dart';
import 'features/files/explorer/s3_object_tile.controller.dart';
import 'features/files/storage.service.dart';
import 'features/files/sync.service.dart';
import 'features/groups/groups.controller.dart';
import 'features/items/items.controller.dart';
import 'features/items/items.service.dart';
import 'features/joined_vaults/joined_vault.controller.dart';
import 'features/main/main_screen.controller.dart';
import 'features/shared_vaults/shared_vault.controller.dart';
import 'features/supabase/app_supabase_db.service.dart';

void init(Flavor flavor, {bool autofill = false}) async {
  Flavors.flavor = flavor;
  isAutofill = autofill;
  final console = Console(name: 'Main');
  console.wtf('Flavor: ${flavor.name}');

  // CAPTURE DART ERRORS
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    secretConfig = SecretsConfig.fromJson(kSecretJson);
    config = CoreServerConfig.fromJson(kConfigJson);

    onboardingBGUri =
        'https://images.unsplash.com/photo-1683849817745-46aa662aad13?q=80&w=600&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

    // init sentry
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    workerManager.init();

    // init core config
    final core = await CoreConfig().init(
      buildMode: BuildMode.production,
      isAppStore: true,
      translationKeys: translationKeys,
      pages: Pages.data,
      initialWindowSize: const Size(1215, 1215),
      onCancelledUpgradeScreen: AppUtils.onCancelledUpgradeScreen,
      onSuccessfulUpgrade: AppUtils.onSuccessfulUpgrade,
      onSignedOut: AppUtils.onSignedOut,
      onSignedIn: AppUtils.onSignedIn,
      logoDarkPath: Images.logo,
      logoLightPath: Images.logoLight,
      allowAnonymousRcUserSync: false,
      adsEnabled: false,
      showUpgradeAppOpen: false,
      // purchasesEnabled: false,
      fcmVapidKey: Secrets.fcmVapidKey,
      // androidGoogleClientId: '',
      appleGoogleClientId:
          '848138515356-79apc9n4ji9ahcruielpkt0k7dnab2r5.apps.googleusercontent.com',
      // webGoogleClientId: '',
      upgradeConfig: UpgradeConfig(
        pricing: AppPricing.data,
        featureTileFontSize: 14,
      ),
      gradientColors: const [
        Color.fromARGB(255, 0, 171, 105),
        Color.fromARGB(255, 0, 255, 213),
      ],
    );

    await core.postInit();

    // services
    Get.lazyPut(() => WalletService());
    Get.lazyPut(() => CipherService());
    Get.lazyPut(() => LisoAutofillService());
    // Get.lazyPut(() => AlchemyService());
    Get.lazyPut(() => SyncService());
    Get.lazyPut(() => FileService());
    Get.lazyPut(() => HiveService());
    Get.lazyPut(() => ItemsService());
    Get.lazyPut(() => GroupsService());
    Get.lazyPut(() => CategoriesService());

    Get.put(AppPersistence());
    Get.put(SecretPersistence());
    Get.put(AppDatabaseService());
    Get.put(AppFunctionsService());
    Get.put(GlobalService());
    Get.put(AppService());

    // controllers
    Get.put(ItemsController());
    Get.put(GroupsController());
    Get.put(CategoriesController());
    Get.put(DrawerMenuController());
    Get.put(MainScreenController());
    Get.put(SharedVaultsController());
    Get.put(JoinedVaultsController());

    // create controllers
    // Get.create(() => S3ObjectTileController());
    Get.spawn(() => S3ObjectTileController());

    await LisoPaths.init();
    await SecretPersistence.open();
    await SecretPersistence.migrate();
    HiveService.init();

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
