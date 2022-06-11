import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  final packageInfo = Rxn<PackageInfo>();

  // GETTERS
  String get appVersion =>
      '${packageInfo()?.version}+${packageInfo()?.buildNumber}';

  // INIT
  @override
  void onInit() async {
    packageInfo.value = await PackageInfo.fromPlatform();
    super.onInit();
  }

  // FUNCTIONS

  void create() async {
    await AuthService.to.signOut(); // just to make sure
    if (!isLocalAuthSupported) {
      return Utils.adaptiveRouteOpen(name: Routes.seed);
    }

    // TODO: custom localized reason
    final authenticated = await LocalAuthService.to.authenticate();

    if (authenticated) {
      final seed = bip39.generateMnemonic(strength: 256);
      final password = Utils.generatePassword();
      await WalletService.to.create(seed, password, true);
      Get.offNamedUntil(Routes.main, (route) => false);
    }
  }

  void import() async {
    await AuthService.to.signOut(); // just to make sure
    Utils.adaptiveRouteOpen(name: Routes.restore);
  }
}
