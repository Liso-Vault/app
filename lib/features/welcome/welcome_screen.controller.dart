import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/firebase/auth.service.dart';
import '../../core/services/local_auth.service.dart';
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
    change(null, status: RxStatus.loading());
    await AuthService.to.signOut(); // just to make sure

    if (!isLocalAuthSupported) {
      change(null, status: RxStatus.success());
      return Utils.adaptiveRouteOpen(name: Routes.seed);
    }

    // TODO: custom localized reason
    final authenticated = await LocalAuthService.to.authenticate();
    if (!authenticated) return change(null, status: RxStatus.success());
    final seed = bip39.generateMnemonic(strength: 256);
    final password = Utils.generatePassword();
    await WalletService.to.create(seed, password, true);
    change(null, status: RxStatus.success());
    Get.offNamedUntil(Routes.main, (route) => false);
  }

  void import() async {
    await AuthService.to.signOut(); // just to make sure
    Utils.adaptiveRouteOpen(name: Routes.restore);
  }
}
