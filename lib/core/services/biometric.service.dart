import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:local_auth/local_auth.dart';

import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

class BiometricService extends GetxService with ConsoleMixin {
  static BiometricService get to => Get.find<BiometricService>();

  // VARIABLES
  final auth = LocalAuthentication();

  // PROPERTIES
  final supported = false.obs;

  @override
  void onInit() async {
    supported.value = GetPlatform.isMobile &&
        await auth.canCheckBiometrics &&
        await auth.isDeviceSupported();

    console.info('init');
    super.onInit();
  }

  Future<bool> authenticate() async {
    if (!supported.value) {
      console.warning('biometrics is not supported');
      return false;
    }

    // TODO: localize
    return await auth.authenticate(
      localizedReason: 'Decrypt and access your local vault',
      options: const AuthenticationOptions(biometricOnly: true),
      authMessages: [
        AndroidAuthMessages(
          signInTitle: 'Authenticate ${ConfigService.to.appName}',
          biometricHint: 'Unlock your vault',
          cancelButton: 'Cancel',
        ),
        const IOSAuthMessages(
          cancelButton: 'Cancel',
        ),
        const WindowsAuthMessages(),
      ],
    );
  }
}
