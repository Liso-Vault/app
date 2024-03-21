// import 'package:app_core/pages/routes.dart';
// import 'package:app_core/services/main.service.dart';
// import 'package:console_mixin/console_mixin.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:liso/features/wallet/wallet.service.dart';

// class AuthenticationMiddleware extends GetMiddleware with ConsoleMixin {
//   @override
//   RouteSettings? redirect(String? route) {
//     // if no vault is locally stored
//     if (!WalletService.to.isSaved) {
//       return const RouteSettings(name: Routes.welcome);
//     }

//     // if the user hasn't unlocked
//     if (Get.currentRoute != Routes.unlock && !WalletService.to.isReady) {
//       // console.wtf('redirect to unlock screen');
//       return const RouteSettings(name: Routes.unlock);
//     }

//     // post init
//     MainService.to.onboarded();
//     return super.redirect(route);
//   }
// }
