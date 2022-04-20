import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/services/wallet.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/main/main_screen.controller.dart';

import '../../features/app/routes.dart';
import '../utils/globals.dart';

class AuthenticationMiddleware extends GetMiddleware with ConsoleMixin {
  @override
  RouteSettings? redirect(String? route) {
    if (!WalletService.to.fileExists) {
      return const RouteSettings(name: Routes.welcome);
    }

    if (Globals.wallet == null) {
      return const RouteSettings(name: Routes.unlock);
    }

    if (!PersistenceService.to.syncConfirmed.val) {
      return const RouteSettings(name: Routes.sync);
    }

    // start down syncing
    MainScreenController.to.downSync();
    return null;
  }
}
