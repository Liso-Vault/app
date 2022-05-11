import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/services/wallet.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/s3/s3.service.dart';

import '../../features/app/routes.dart';
import '../utils/globals.dart';

class AuthenticationMiddleware extends GetMiddleware with ConsoleMixin {
  static bool ignoreSync = false;

  @override
  RouteSettings? redirect(String? route) {
    console.wtf('redirect(): $route');

    if (!WalletService.to.exists) {
      return const RouteSettings(name: Routes.welcome);
    }

    if (Globals.wallet == null) {
      return const RouteSettings(name: Routes.unlock);
    }

    if (!PersistenceService.to.syncConfirmed.val) {
      return const RouteSettings(name: Routes.syncSettings);
    }

    if (!ignoreSync &&
        !S3Service.to.inSync.value &&
        PersistenceService.to.sync.val) {
      return const RouteSettings(name: Routes.syncing);
    }

    // init
    MainScreenController.to.load();
    S3Service.to.fetchStorageSize();

    return super.redirect(route);
  }
}
