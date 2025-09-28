import 'package:app_core/config.dart';

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
    change(GetStatus.success(null));
    super.onInit();
  }

  // FUNCTIONS

  void create() async {
    await Utils.adaptiveRouteOpen(
      name: Routes.upgrade,
      parameters: {'cooldown': CoreConfig().premiumScreenCooldown.toString()},
    );

    change(GetStatus.loading());

    if (!isLocalAuthSupported) {
      change(GetStatus.success(null));
      return Utils.adaptiveRouteOpen(name: AppRoutes.seed);
    }

    // TODO: custom localized reason
    final authenticated = await LocalAuthService.to.authenticate(
      subTitle: 'create_your_vault'.tr,
      body: 'authenticate_to_verify_and_approve_this_action'.tr,
    );

    if (!authenticated) return change(GetStatus.success(null));
    final seed = bip39.generateMnemonic(strength: 256);
    final password = AppUtils.generatePassword();
    await WalletService.to.create(seed, password, true);
    change(GetStatus.success(null));

    NotificationsService.to.notify(
      title: 'welcome'.tr,
      body: 'your_vault_has_been_created'.tr,
    );
  }

  void restore() {
    Utils.adaptiveRouteOpen(name: AppRoutes.restore);
  }
}
