import 'package:app_core/firebase/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/supabase/supabase_database.service.dart';
import 'package:get/get.dart';
import 'package:liso/features/config/secrets.dart';

import '../config/license.model.dart';

class AppDatabaseService extends DatabaseService {
  static AppDatabaseService get to => Get.find();

  // VARIABLES
  final configSyncing = true.obs;

  @override
  void onInit() async {
    // set default license config
    licenseConfig = LicenseConfig.fromJson(kLicenseJson);

    final result = await DatabaseService.to.configuration();

    result.fold(
      (error) {
        configSyncing.value = false;
        console.wtf('Remote Configuration Failed: $error');
      },
      (response) async {
        // console.wtf('Remote Config Success!');

        // appConfig = response.app;
        // extraConfig = ExtraConfig.fromJson(response.extra);
        licenseConfig = LicenseConfig.fromJson(response.license);
        configSyncing.value = false;

        // Future.delayed(2.seconds).then((value) {
        //   AlchemyService.to.init();
        //   AlchemyService.to.load();
        // });

        final disabled = versions.disabled.contains(
          metadataApp.buildNumberInt,
        );

        final updateRequired = versions.min > metadataApp.buildNumberInt;

        if (disabled || updateRequired) {
          Get.toNamed(Routes.update);
        }
      },
    );

    super.onInit();
  }
}
