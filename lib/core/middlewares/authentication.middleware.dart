import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../features/app/routes.dart';

class AuthenticationMiddleware extends GetMiddleware with ConsoleMixin {
  static bool initialized = false;
  static bool signedIn = false;
  static bool skipRedirect = false;

  @override
  RouteSettings? redirect(String? route) {
    if (skipRedirect) return super.redirect(route);

    if (!WalletService.to.isSaved) {
      return const RouteSettings(name: Routes.welcome);
    }

    if (!signedIn) {
      return const RouteSettings(name: Routes.unlock);
    }

    // first time initialization
    if (!initialized) {
      CrashlyticsService.to.configure();
    }

    // post init
    MainScreenController.to.postInit();
    initialized = true;
    console.wtf('welcome');
    return super.redirect(route);
  }
}
