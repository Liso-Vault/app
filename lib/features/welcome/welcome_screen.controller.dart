import 'package:app_core/controllers/pro.controller.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/notifications/notifications.manager.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/services/local_auth.service.dart';
import 'package:app_core/utils/utils.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/middlewares/authentication.middleware.dart';
import 'package:liso/core/persistence/persistence.dart';

import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../main/main_screen.controller.dart';
import '../wallet/wallet.service.dart';

class WelcomeScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void create() async {
    // show upgrade screen
    if (!AppPersistence.to.upgradeScreenShown.val && !ProController.to.isPro) {
      await Utils.adaptiveRouteOpen(name: Routes.upgrade);
    }

    change(null, status: RxStatus.loading());

    if (!isLocalAuthSupported) {
      change(null, status: RxStatus.success());
      return Utils.adaptiveRouteOpen(name: AppRoutes.seed);
    }

    // TODO: custom localized reason
    final authenticated = await LocalAuthService.to.authenticate(
      subTitle: 'Create your vault',
      body: 'Authenticate to verify and approve this action',
    );

    if (!authenticated) return change(null, status: RxStatus.success());
    final seed = bip39.generateMnemonic(strength: 256);
    final password = AppUtils.generatePassword();
    await WalletService.to.create(seed, password, true);
    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Welcome to ${ConfigService.to.appName}',
      body: 'Your vault has been created',
    );

    AuthenticationMiddleware.signedIn = true;
    MainScreenController.to.navigate();
  }

  void restore() async {
    Utils.adaptiveRouteOpen(name: AppRoutes.restore);
  }
}
