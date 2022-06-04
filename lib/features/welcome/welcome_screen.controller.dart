import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:random_password_generator/random_password_generator.dart';
import 'package:bip39/bip39.dart' as bip39;

import '../../core/firebase/auth.service.dart';
import '../../core/services/biometric.service.dart';
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
    if (!isLocalAuthSupported) return Get.toNamed(Routes.mnemonic);

    // TODO: custom localized reason
    final authenticated = await LocalAuthService.to.authenticate();

    if (authenticated) {
      final seed = bip39.generateMnemonic(strength: 256);

      final password = RandomPasswordGenerator().randomPassword(
        letters: true,
        numbers: true,
        specialChar: true,
        uppercase: true,
        passwordLength: 15,
      );

      await WalletService.to.create(seed, password, true);
      Get.offAllNamed(Routes.configuration);
    }
  }

  void import() async {
    await AuthService.to.signOut(); // just to make sure
    Get.toNamed(Routes.import);
  }
}
