import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/services/alchemy.service.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../features/app/routes.dart';

class AuthenticationMiddleware extends GetMiddleware with ConsoleMixin {
  static bool ignoreSync = false;

  @override
  RouteSettings? redirect(String? route) {
    if (!WalletService.to.saved) {
      return const RouteSettings(name: Routes.welcome);
    }

    if (WalletService.to.wallet == null) {
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

    CrashlyticsService.to.configure();
    MainScreenController.to.load();

    // record metadata
    S3Service.to.fetchStorageSize().then((info) {
      if (info == null) return;
      FirestoreService.to.record(
        objects: info.objects.length,
        totalSize: info.totalSize,
      );
    });

    return super.redirect(route);
  }
}
