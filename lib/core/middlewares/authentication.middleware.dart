import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/authentication.service.dart';
import 'package:liso/core/utils/console.dart';

import '../../features/app/routes.dart';
import '../utils/globals.dart';

class AuthenticationMiddleware extends GetMiddleware with ConsoleMixin {
  final authService = Get.find<AuthenticationService>();

  @override
  RouteSettings? redirect(String? route) {
    if (!authService.isAuthenticated) {
      return const RouteSettings(name: Routes.welcome);
    }

    if (Globals.wallet == null) {
      return const RouteSettings(name: Routes.unlock);
    }

    // TODO: if IPFS Sync is on, then sync first

    return null;
  }
}
