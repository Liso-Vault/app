import 'package:app_core/config.dart';
import 'package:app_core/config/app.model.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/services/local_auth.service.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/utils/utils.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

import '../../core/utils/utils.dart';
import '../app/routes.dart';
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
    await Utils.adaptiveRouteOpen(
      name: Routes.upgrade,
      parameters: {'cooldown': CoreConfig().premiumScreenCooldown.toString()},
    );

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

    NotificationsService.to.notify(
      title: 'Welcome to ${appConfig.name}',
      body: 'Your vault has been created',
    );
  }

  void restore() {
    Utils.adaptiveRouteOpen(name: AppRoutes.restore);
  }
}
