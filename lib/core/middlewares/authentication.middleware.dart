import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/services/alchemy.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../features/app/routes.dart';

class AuthenticationMiddleware extends GetMiddleware with ConsoleMixin {
  static bool ignoreSync = false;
  static bool initialized = false;

  @override
  RouteSettings? redirect(String? route) {
    if (kReleaseMode == ReleaseMode.beta &&
        !ConfigService.to.app.beta.enabled) {
      return const RouteSettings(name: Routes.disabledBeta);
    }

    if (!WalletService.to.isSaved) {
      return const RouteSettings(name: Routes.welcome);
    }

    if (!WalletService.to.isReady) {
      return const RouteSettings(name: Routes.unlock);
    }

    // load balances
    AlchemyService.to.init();
    AlchemyService.to.load();

    if (!Persistence.to.syncConfirmed.val) {
      return const RouteSettings(name: Routes.configuration);
    }

    if (!ignoreSync && !S3Service.to.inSync.value && Persistence.to.sync.val) {
      return const RouteSettings(name: Routes.syncing);
    }

    // first time initialization
    if (!initialized) CrashlyticsService.to.configure();
    MainScreenController.to.load();
    Globals.init();
    AuthService.to.signIn();
    initialized = true;
    console.wtf('welcome');
    return super.redirect(route);
  }
}
