import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/firebase/auth.service.dart';
import '../../core/services/local_auth.service.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../wallet/wallet.service.dart';

class WelcomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WelcomeScreenController(), fenix: true);
  }
}

class WelcomeScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void create() async {
    await AuthService.to.signOut(); // just to make sure

    if (!isLocalAuthSupported) {
      return Utils.adaptiveRouteOpen(name: Routes.seed);
    }

    // TODO: custom localized reason
    final authenticated = await LocalAuthService.to.authenticate();
    if (!authenticated) return;
    final seed = bip39.generateMnemonic(strength: 256);
    final password = Utils.generatePassword();
    await WalletService.to.create(seed, password, true);
    Get.offNamedUntil(Routes.main, (route) => false);
  }

  void import() async {
    await AuthService.to.signOut(); // just to make sure
    Utils.adaptiveRouteOpen(name: Routes.restore);
  }
}
