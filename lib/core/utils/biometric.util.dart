import 'package:biometric_storage/biometric_storage.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:local_auth/local_auth.dart';

class BiometricUtils {
  static final console = Console(name: 'BiometricUtils');
  static bool touchFaceIdSupported = false;

  static Future<void> init() async {
    if (GetPlatform.isMobile) {
      touchFaceIdSupported = await LocalAuthentication().canCheckBiometrics;
    }

    console.info('init');
  }

  static Future<bool> save(
    String password, {
    required String key,
  }) async {
    if (!await canAuthenticate()) return false;

    final storage = await getStorage(
      key,
      title: 'Secure ${ConfigService.to.appName}',
    );

    try {
      await storage.write(password);
      return true;
    } catch (e) {
      console.error('biometric storage error: $e');
      return false;
    }
  }

  static Future<String?> obtain(String key) async {
    if (!await canAuthenticate()) return null;
    final storage = await getStorage(key);

    try {
      return await storage.read();
    } catch (e) {
      console.error('biometric storage error: $e');
      return null;
    }
  }

  static Future<void> delete(String key) async {
    if (!await canAuthenticate()) return;
    final storage = await getStorage(key);
    await storage.delete();
  }

  static Future<BiometricStorageFile> getStorage(
    String name, {
    String? title,
  }) async {
    title = title ?? 'Unlock ${ConfigService.to.appName}';
    final preSubTitle = 'securely access ${ConfigService.to.appName}';

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

  static Future<bool> canAuthenticate() async {
    final response = await BiometricStorage().canAuthenticate();
    console.warning('biometric: $response');
    return response == CanAuthenticateResponse.success;
  }
}
