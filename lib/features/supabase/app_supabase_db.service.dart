import 'package:app_core/config/app.model.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/supabase/supabase_database.service.dart';
import 'package:get/get.dart';

import '../../core/services/alchemy.service.dart';
import '../config/extra.model.dart';
import '../config/license.model.dart';

class AppDatabaseService extends DatabaseService {
  static AppDatabaseService get to => Get.find();

  // VARIABLES
  final configSyncing = true.obs;

  @override
  void onInit() async {
    final result = await DatabaseService.to.configuration();

    result.fold(
      (error) {
        configSyncing.value = false;
        console.wtf('Remote Configuration Failed: $error');
      },
      (response) async {
        appConfig = response.app;
        licenseConfig = LicenseConfig.fromJson(response.license);
        extraConfig = ExtraConfig.fromJson(response.extra);

        Future.delayed(2.seconds).then((value) {
          AlchemyService.to.init();
          AlchemyService.to.load();
        });

        configSyncing.value = false;
        console.wtf('Remote Configuration Success');

        if (isBeta &&
            !appConfig.build.beta.contains(metadataApp.buildNumberInt)) {
          await Future.delayed(1.seconds).then(
            (value) => Get.toNamed(Routes.disabledBeta),
          );
        }
      },
    );

    super.onInit();
  }
}
