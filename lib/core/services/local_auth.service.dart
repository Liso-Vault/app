import 'package:app_settings/app_settings.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
// import 'package:local_auth_windows/local_auth_windows.dart';

class LocalAuthService extends GetxService with ConsoleMixin {
  static LocalAuthService get to => Get.find<LocalAuthService>();

  // VARIABLES
  final auth = LocalAuthentication();

  // PROPERTIES

  // INIT

  // FUNCTIONS
  Future<bool> authenticate() async {
    bool authenticated = false;

    try {
      // TODO: localize
      authenticated = await auth.authenticate(
        localizedReason: 'Decrypt and access your local vault',
        options: const AuthenticationOptions(),
        authMessages: [
          AndroidAuthMessages(
            signInTitle: 'Authenticate ${ConfigService.to.appName}',
            biometricHint: 'Unlock your vault',
            cancelButton: 'Cancel',
          ),
          const IOSAuthMessages(cancelButton: 'Cancel'),
          // const WindowsAuthMessages(),
        ],
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        UIUtils.showSimpleDialog(
          'Screenlock Required',
          "Please turn it on to continue.",
          closeText: 'Cancel',
          actionText: 'Open Settings',
          action: () {
            Get.back();
            AppSettings.openLockAndPasswordSettings();
          },
        );
      } else if (e.code == auth_error.notEnrolled) {
        UIUtils.showSimpleDialog(
          'Biometrics Required',
          "Please turn it on to continue.",
          closeText: 'Cancel',
          actionText: 'Open Settings',
          action: () {
            Get.back();
            AppSettings.openLockAndPasswordSettings();
          },
        );
      } else if (e.code == auth_error.passcodeNotSet) {
        UIUtils.showSimpleDialog(
          GetPlatform.isIOS ? 'Passcode Not Set' : 'Screenlock Not Set',
          "Please turn it on to continue.",
          closeText: 'Cancel',
          actionText: 'Open Settings',
          action: () {
            Get.back();
            AppSettings.openLockAndPasswordSettings();
          },
        );
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        UIUtils.showSimpleDialog(
          'Locked Out',
          "Because of too many attempts you've been locked out. Please try again later.",
        );
      } else if (e.code == auth_error.otherOperatingSystem) {
        UIUtils.showSimpleDialog(
          'Unsupported OS',
          'Please report to the developer',
        );
      } else {
        UIUtils.showSimpleDialog(
          'Unknown Error',
          'Please report to the developer! $e',
        );
      }

      console.error('PlatformException: ${e.toString()}');
      return false;
    } catch (e) {
      console.error('error: ${e.toString()}');

      UIUtils.showSimpleDialog(
        'Unknown Error',
        'Please report to the developer! $e',
      );

      return false;
    }

    return authenticated;
  }
}
