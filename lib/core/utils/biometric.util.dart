import 'package:biometric_storage/biometric_storage.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supercharged/supercharged.dart';

import 'console.dart';

class BiometricUtils {
  static final console = Console(name: 'BiometricUtils');

  static bool ready = false;

  static Future<void> init() async {
    // biometrucs
    final localAuth = LocalAuthentication();
    final supported = await localAuth.canCheckBiometrics;
    ready = GetPlatform.isMobile && supported;
  }

  static Future<String?> getPassword() async {
    // only for mobile devices
    if (!BiometricUtils.ready) {
      console.info('biometrics not applicable');
      return null;
    }

    await Future.delayed(250.milliseconds);
    // TODO: do we still need this
    final response = await BiometricStorage().canAuthenticate();
    if (response != CanAuthenticateResponse.success) {
      console.warning('biometric authentication not supported');
      return null;
    }

    final passwordStorage = await BiometricStorage().getStorage(
      kBiometricPasswordKey,
    );

    String? biometricPassword;

    try {
      biometricPassword = await passwordStorage.read();
    } catch (e) {
      console.error('biometric storage error: $e');
      return null;
    }

    if (biometricPassword == null) {
      console.warning('no password stored in biometric storage');
      return null;
    }

    console.info('biometric password: $biometricPassword');
    return biometricPassword;
  }
}
