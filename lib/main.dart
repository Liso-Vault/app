import 'dart:async';
import 'dart:convert';

import 'package:app_core/config.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/firebase/config/models/config_root.model.dart';
import 'package:app_core/firebase/crashlytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/upgrade/upgrade_config.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: library_prefixes
import 'package:firebase_dart/firebase_dart.dart' as firebaseDesktop;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/model/config_app_domains.model.dart';
import 'package:liso/core/firebase/model/config_limits.model.dart';
import 'package:liso/core/firebase/model/config_web3.model.dart';
import 'package:liso/core/hive/hive.service.dart';
import 'package:liso/core/persistence/persistence.secret.dart';
import 'package:liso/core/services/alchemy.service.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/features/autofill/autofill.service.dart';
import 'package:liso/features/groups/groups.service.dart';
import 'package:liso/features/supabase/supabase_functions.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:liso/resources/resources.dart';
import 'package:secrets/firebase_options.dart';
import 'package:secrets/secrets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:worker_manager/worker_manager.dart';

import 'core/flavors/flavors.dart';
import 'core/liso/liso_paths.dart';
import 'core/persistence/persistence.dart';
import 'core/translations/data.dart';
import 'core/utils/globals.dart';
import 'features/app/app.dart';
import 'features/app/pages.dart';
import 'features/categories/categories.controller.dart';
import 'features/categories/categories.service.dart';
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

void initUpgradeConfig() {
  String formatKNumber(int number) {
    if (number == 1000000) {
      return 'Unlimited';
    } else {
      return kFormatter.format(number);
    }
  }

  final upgradeConfig = UpgradeConfig(
    features: [
      if (isIAPSupported) ...[
        // TODO: temporary
        // controller.promoText
      ] else ...[
        '1 ${'week'.tr} ${'free_trial'.tr}',
      ],
      'cancel_anytime'.tr,
      '${formatKNumber(configLimits.pro.items)} Items',
      '${formatKNumber(configLimits.pro.devices)} Devices',
      '2FA Authenticator',
      '${filesize(1073741824)} Encrypted Cloud Storage',
      '${formatKNumber(configLimits.pro.sharedMembers)} Shared Members',
      '${formatKNumber(configLimits.pro.protectedItems)} Protected Items',
      'Password Health',
      'Priority Support',
      'Encryption Tool',
      '${formatKNumber(configLimits.pro.backups)} Vault Backups',
      '${filesize(configLimits.pro.uploadSize)} Upload File Size',
      '${formatKNumber(configLimits.pro.files)} Max Stored Files',
      'Undo Trash up to ${formatKNumber(configLimits.pro.trashDays)} Days',
      '${formatKNumber(configLimits.pro.customVaults)} Custom Vaults',
      '${formatKNumber(configLimits.pro.customCategories)} Custom Categories',
      'Autosave + Autofill',
      'Generate Passwords',
      'Biometric Auth',
      'Offline Mode',
    ],
    upcomingFeatures: [
      'Self-Hostable',
      'Breach Scanner',
      'NFC Keycard Support',
      'YubiKey Support',
    ],
    darkDecoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Colors.black,
          Color(0xFF173030),
        ],
      ),
    ),
  );

  CoreConfig().upgradeConfig = upgradeConfig;
}

void init(Flavor flavor, {bool autofill = false}) async {
  Flavors.flavor = flavor;
  isAutofill = autofill;
  final console = Console(name: 'Main');
  console.wtf('Flavor: ${flavor.name}');

  // CAPTURE DART ERRORS
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // improve performance
    GestureBinding.instance.resamplingEnabled = true;
    // init sentry
    if (isWindowsLinux) {
      await SentryFlutter.init(
        (options) {
          options.dsn = Secrets.configs.secrets['sentry']?['dsn'] as String;
        },
      );
    }

    // init firebase
    await Firebase.initializeApp(options: Secrets.firebaseOptions);

    if (isWindowsLinux) {
      firebaseDesktop.FirebaseDart.setup();

      await firebaseDesktop.Firebase.initializeApp(
        options: firebaseDesktop.FirebaseOptions.fromMap(
          DefaultFirebaseOptions.currentPlatform.asMap,
        ),
      );
    }

    // warm up executor
    await Executor().warmUp(
      log: true,
      isolatesCount: kDebugMode ? 2 : 50,
    );

    // init core config
    final core = CoreConfig().init(
      persistenceCipherKey: Secrets.persistenceKey,
      translationKeys: translationKeys,
      pages: Pages.data,
      // onCloseUpgradeScreen: AppUtils.showContestDialog, // TODO: temporary
      logoDarkPath: Images.logo,
      logoLightPath: Images.logo, // TODO: light logo
      allowAnonymousRcUserSync: false,
      gradientColors: const [
        Color.fromARGB(255, 0, 171, 105),
        Color.fromARGB(255, 0, 255, 213),
      ],
    );

    // services
    Get.lazyPut(() => AppSupabaseFunctionsService());
    Get.lazyPut(() => AppPersistence());
    Get.lazyPut(() => SecretPersistence());
    Get.lazyPut(() => WalletService());
    Get.lazyPut(() => CipherService());
    Get.lazyPut(() => LisoAutofillService());
    Get.lazyPut(() => AlchemyService());
    Get.lazyPut(() => SyncService());
    Get.lazyPut(() => StorageService());
    Get.lazyPut(() => HiveService());
    Get.lazyPut(() => ItemsService());
    Get.lazyPut(() => GroupsService());
    Get.lazyPut(() => CategoriesService());

    // controllers
    Get.put(ItemsController());
    Get.put(GroupsController());
    Get.put(CategoriesController());
    Get.put(DrawerMenuController());
    Get.put(MainScreenController());
    Get.put(SharedVaultsController());
    Get.put(JoinedVaultsController());

    // create controllers
    Get.create(() => S3ObjectTileController());

    // initializations
    await ConfigService.to.init(
      postInit: (parameters) {
        configLimits = ConfigLimits.fromJson(
          jsonDecode(
            ConfigValue.fromJson(parameters["limits_config"])
                .defaultValue
                .value,
          ),
        );

        configAppDomains = ConfigAppDomains.fromJson(
          jsonDecode(
            ConfigValue.fromJson(parameters["app_domains_config"])
                .defaultValue
                .value,
          ),
        );

        configWeb3 = ConfigWeb3.fromJson(
          jsonDecode(
            ConfigValue.fromJson(parameters["web3_config"]).defaultValue.value,
          ),
        );

        initUpgradeConfig();

        // load balances
        AlchemyService.to.init();
        AlchemyService.to.load();
      },
    );

    await core.postInit();
    await LisoPaths.init();
    await SecretPersistence.open();
    await SecretPersistence.migrate();
    HiveService.init();

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
