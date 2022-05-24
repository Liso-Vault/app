import 'package:biometric_storage/biometric_storage.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:local_auth/local_auth.dart';

class BiometricUtils {
  static final console = Console(name: 'BiometricUtils');
  static final auth = LocalAuthentication();
  static bool supported = false;

  static Future<void> init() async {
    if (!GetPlatform.isMobile) return;
    supported = await auth.canCheckBiometrics && await auth.isDeviceSupported();
    console.info('init');
  }

  static Future<BiometricStorageFile> getStorage(
    String name, {
    String? title,
  }) async {
    title = title ?? 'Unlock ${ConfigService.to.appName}';
    final preSubTitle = 'Securely Access ${ConfigService.to.appName}';

    // TODO: localize
    final applePrompt = IosPromptInfo(
      accessTitle: preSubTitle,
      saveTitle: title,
    );

    // TODO: localize
    final androidPrompt = AndroidPromptInfo(
      title: title,
      subtitle: '${ConfigService.to.appName} Vault',
      description: GetUtils.capitalizeFirst(preSubTitle),
    );

    final passwordStorage = await BiometricStorage().getStorage(
      name,
      promptInfo: PromptInfo(
        macOsPromptInfo: applePrompt,
        iosPromptInfo: applePrompt,
        androidPromptInfo: androidPrompt,
      ),
    );

    return passwordStorage;
  }

  static Future<bool> authenticate() async {
    if (!supported) {
      console.error('cannot authenticate via biometrics');
      return false;
    }

    return await auth.authenticate(
      localizedReason: 'Unlock ${ConfigService.to.appName}',
      options: const AuthenticationOptions(biometricOnly: true),
      // authMessages: const [
      //   AndroidAuthMessages(
      //     signInTitle: 'Oops! Biometric authentication required!',
      //     cancelButton: 'No thanks',
      //   ),
      //   IOSAuthMessages(
      //     cancelButton: 'No thanks',
      //   ),
      // ],
    );
  }
}
