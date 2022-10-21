import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/models/config_web3.model.dart';
import 'package:liso/features/connectivity/connectivity.service.dart';
import 'package:secrets/secrets.dart';

import '../../../features/app/routes.dart';
import '../../../features/pro/pro.controller.dart';
import '../../../features/supabase/supabase_auth.service.dart';
import '../../persistence/persistence.secret.dart';
import '../../utils/globals.dart';
import 'models/config_app.model.dart';
import 'models/config_app_domains.model.dart';
import 'models/config_general.model.dart';
import 'models/config_limits.model.dart';
import 'models/config_root.model.dart';
import 'models/config_secrets.model.dart';
import 'models/config_users.model.dart';

class ConfigService extends GetxService with ConsoleMixin {
  static ConfigService get to => Get.find();

  // VARIABLES
  var general = const ConfigGeneral();
  var app = const ConfigApp();
  var secrets = const ConfigSecrets();
  var web3 = const ConfigWeb3();
  var limits = const ConfigLimits();
  var users = const ConfigUsers();
  var appDomains = const ConfigAppDomains();

  bool remoteFetched = false;

  // GETTERS
  String get appName => general.app.name;
  String get devName => general.developer.name;
  bool get isReady => secrets.supabase.url.isNotEmpty;

  // INIT

  // FUNCTIONS
  Future<void> init() async {
    // pre-populate with local as defaults
    _prePopulate();
    fetchFromFunctions();
  }

  Future<void> fetchFromFunctions() async {
    final result = await getRemoteConfig();

    result.fold(
      (error) => console.info('remote config! functions: error: $error'),
      (root) {
        app = root.parameters.appConfig;
        SecretPersistence.to.configApp.val = jsonEncode(app.toJson());

        secrets = root.parameters.secretsConfig;
        SecretPersistence.to.configSecrets.val = jsonEncode(secrets.toJson());

        web3 = root.parameters.web3Config;
        SecretPersistence.to.configWeb3.val = jsonEncode(web3.toJson());

        limits = root.parameters.limitsConfig;
        SecretPersistence.to.configLimits.val = jsonEncode(limits.toJson());

        users = root.parameters.usersConfig;
        SecretPersistence.to.configUsers.val = jsonEncode(users.toJson());

        general = root.parameters.generalConfig;
        SecretPersistence.to.configGeneral.val = jsonEncode(general.toJson());

        appDomains = root.parameters.appDomainsConfig;
        SecretPersistence.to.configAppDomains.val =
            jsonEncode(appDomains.toJson());

        remoteFetched = true;
        console.wtf('remote config! functions: success');
      },
    );

    postFetch();
  }

  Future<Either<String, ConfigRoot>> getRemoteConfig() async {
    if (!ConnectivityService.to.connected.value) {
      return const Left('no internet connection');
    }

    console.info('remote config! fetching...');
    HttpsCallableResult? result;

    try {
      result = await FirebaseFunctions.instance
          .httpsCallable('getRemoteConfig')
          .call();
    } on FirebaseFunctionsException catch (e) {
      return Left('error fetching remote config: $e');
    }

    // console.wtf('remote config! response: ${result.data}');

    if (result.data == false) {
      return const Left('failed to fetch remote config');
    }

    return Right(ConfigRoot.fromJson(jsonDecode(result.data)));
  }

  Future<void> _prePopulate() async {
    app = ConfigApp.fromJson(
      SecretPersistence.to.configApp.val.isEmpty
          ? Secrets.configs.app
          : jsonDecode(SecretPersistence.to.configApp.val),
    );

    secrets = ConfigSecrets.fromJson(
      SecretPersistence.to.configSecrets.val.isEmpty
          ? Secrets.configs.secrets
          : jsonDecode(SecretPersistence.to.configSecrets.val),
    );

    web3 = ConfigWeb3.fromJson(
      SecretPersistence.to.configWeb3.val.isEmpty
          ? Secrets.configs.web3
          : jsonDecode(SecretPersistence.to.configWeb3.val),
    );

    limits = ConfigLimits.fromJson(
      SecretPersistence.to.configLimits.val.isEmpty
          ? Secrets.configs.limits
          : jsonDecode(SecretPersistence.to.configLimits.val),
    );

    users = ConfigUsers.fromJson(
      SecretPersistence.to.configUsers.val.isEmpty
          ? Secrets.configs.users
          : jsonDecode(SecretPersistence.to.configUsers.val),
    );

    general = ConfigGeneral.fromJson(
      SecretPersistence.to.configGeneral.val.isEmpty
          ? Secrets.configs.general
          : jsonDecode(SecretPersistence.to.configGeneral.val),
    );

    appDomains = ConfigAppDomains.fromJson(
      SecretPersistence.to.configAppDomains.val.isEmpty
          ? Secrets.configs.appDomains
          : jsonDecode(SecretPersistence.to.configAppDomains.val),
    );
  }

  void postFetch() {
    // initialize supabase
    SupabaseAuthService.to.init();
    ProController.to.init();

    // check if update is required
    if (app.build.min > int.parse(Globals.metadata!.app.buildNumber)) {
      console.error('### must update');
      Get.toNamed(Routes.update);
    }
  }
}
