import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string_generator/random_string_generator.dart';

import '../../features/files/storage.service.dart';
import '../../features/supabase/model/object.model.dart';
import '../../features/supabase/supabase_functions.service.dart';
import '../../resources/resources.dart';
import '../services/app.service.dart';
import 'globals.dart';

class AppUtils {
  // VARIABLES
  static final console = Console(name: 'Utils');
  static final authenticated = false.obs;

  // GETTERS

  // FUNCTIONS

  static Future<void> showQR(
    String data, {
    required String title,
    required String subTitle,
  }) async {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Center(
            child: QrImageView(
              data: data,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          subTitle,
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );

    await Get.dialog(AlertDialog(
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: isSmallScreen
          ? content
          : Container(
              constraints: const BoxConstraints(maxHeight: 600),
              width: 450,
              child: content,
            ),
      actions: [
        TextButton(
          onPressed: Get.close,
          child: Text('okay'.tr),
        ),
      ],
    ));
  }

  static Icon categoryIcon(String category, {Color? color, double? size}) {
    IconData? iconData;

    if (category == LisoItemCategory.cryptoWallet.name) {
      iconData = Iconsax.wallet_outline;
      color = Colors.redAccent;
    } else if (category == LisoItemCategory.login.name) {
      iconData = Iconsax.login_outline;
      color = Colors.blueAccent;
    } else if (category == LisoItemCategory.password.name) {
      iconData = Iconsax.password_check_outline;
      color = Colors.teal;
    } else if (category == LisoItemCategory.identity.name) {
      iconData = Iconsax.user_outline;
      color = Colors.purpleAccent;
    } else if (category == LisoItemCategory.note.name) {
      iconData = Iconsax.note_text_outline;
      color = Colors.pinkAccent;
    } else if (category == LisoItemCategory.insurance.name) {
      iconData = Iconsax.shield_tick_outline;
      color = Colors.pinkAccent;
    } else if (category == LisoItemCategory.healthInsurance.name) {
      iconData = Iconsax.health_outline;
      color = Colors.pink;
    } else if (category == LisoItemCategory.cashCard.name) {
      iconData = Iconsax.card_outline;
      color = Colors.deepOrange;
    } else if (category == LisoItemCategory.bankAccount.name) {
      iconData = Iconsax.bank_outline;
      color = Colors.amberAccent;
    } else if (category == LisoItemCategory.medicalRecord.name) {
      iconData = Iconsax.health_outline;
      color = Colors.red;
    } else if (category == LisoItemCategory.passport.name) {
      iconData = Iconsax.airplane_square_outline;
      color = Colors.purple;
    } else if (category == LisoItemCategory.server.name) {
      iconData = Iconsax.cloud_outline;
      color = Colors.blueAccent;
    } else if (category == LisoItemCategory.softwareLicense.name) {
      iconData = Iconsax.code_1_outline;
      color = Colors.indigoAccent;
    } else if (category == LisoItemCategory.apiCredential.name) {
      iconData = Iconsax.code_outline;
      color = Colors.lime;
    } else if (category == LisoItemCategory.database.name) {
      iconData = Iconsax.document_outline;
      color = Colors.orangeAccent;
    } else if (category == LisoItemCategory.driversLicense.name) {
      iconData = Iconsax.car_outline;
      color = Colors.teal;
    } else if (category == LisoItemCategory.email.name) {
      iconData = Iconsax.message_outline;
      color = Colors.green;
    } else if (category == LisoItemCategory.membership.name) {
      iconData = Iconsax.personalcard_outline;
      color = Colors.red;
    } else if (category == LisoItemCategory.outdoorLicense.name) {
      iconData = Iconsax.activity_outline;
      color = Colors.pink;
    } else if (category == LisoItemCategory.rewardsProgram.name) {
      iconData = Iconsax.award_outline;
      color = Colors.amber;
    } else if (category == LisoItemCategory.socialSecurity.name) {
      iconData = Iconsax.security_card_outline;
      color = Colors.blue;
    } else if (category == LisoItemCategory.wirelessRouter.name) {
      iconData = Iconsax.home_wifi_outline;
      color = Colors.green;
    } else if (category == LisoItemCategory.encryption.name) {
      iconData = Iconsax.key_outline;
    } else if (category == LisoItemCategory.otp.name) {
      iconData = LineAwesome.mobile_alt_solid;
      color = Colors.deepPurple;
    } else if (category == LisoItemCategory.custom.name) {
      iconData = Iconsax.category_outline;
    } else {
      iconData = Iconsax.category_outline;
    }

    return Icon(iconData, color: color, size: size);
  }

  static String? validateUri(String data) {
    final uri = Uri.tryParse(data);

    if (uri != null &&
        !uri.hasQuery &&
        uri.hasEmptyPath &&
        uri.hasPort &&
        uri.host.isNotEmpty) {
      return null;
    }

    return 'Invalid Server URL';
  }

  // TODO: folder validation
  static String? validateFolderName(String name) {
    if (name.isNotEmpty) return null;
    return 'Invalid Folder Name';
  }

  static Widget s3ContentIcon(S3Object object) {
    if (!object.isFile) return const Icon(Iconsax.folder_open_outline);
    IconData iconData = Iconsax.document_1_outline;
    if (object.fileType == null) return Icon(iconData);

    switch (object.fileType!) {
      case 'liso':
        return RemoteImage(
          url: 'https://i.imgur.com/GW4HQ1r.png',
          height: 25,
          failWidget: Image.asset(Images.logo, height: 25),
        );
      case 'image':
        iconData = Iconsax.gallery_outline;
        break;
      case 'video':
        iconData = Iconsax.play_outline;
        break;
      case 'archive':
        iconData = Iconsax.archive_outline;
        break;
      case 'audio':
        iconData = Iconsax.music_outline;
        break;
      case 'code':
        iconData = Icons.code;
        break;
      case 'book':
        iconData = Iconsax.book_1_outline;
        break;
      case 'exec':
        iconData = Iconsax.code_outline;
        break;
      case 'web':
        iconData = Iconsax.chrome_outline;
        break;
      case 'sheet':
        iconData = Iconsax.document_text_outline;
        break;
      case 'text':
        iconData = Iconsax.document_outline;
        break;
      case 'font':
        iconData = Iconsax.text_block_outline;
        break;
    }

    return Icon(iconData);
  }

  static String generatePassword() {
    return RandomStringGenerator(
      fixedLength: 15,
      mustHaveAtLeastOneOfEach: true,
    ).generate();
  }

  static String? validatePassword(String? text) {
    const min = 8;
    const max = 100;

    if (text == null || text.isEmpty) {
      return 'Enter your password';
    } else if (text.length < min) {
      return 'Vault password must be at least $min characters';
    } else if (text.length > max) {
      return "That's a lot of a password";
    }

    return null;
  }

  static String strengthName(PasswordStrength strength) {
    String name = 'very_weak'.tr; // VERY WEAK

    if (strength == PasswordStrength.WEAK) {
      name = 'weak'.tr;
    } else if (strength == PasswordStrength.GOOD) {
      name = 'good'.tr;
    } else if (strength == PasswordStrength.STRONG) {
      name = 'strong'.tr;
    }

    return name;
  }

  static Color? strengthColor(PasswordStrength strength) {
    Color color = Colors.red; // VERY WEAK

    if (strength == PasswordStrength.WEAK) {
      color = Colors.orange;
    } else if (strength == PasswordStrength.GOOD) {
      color = Colors.lime;
    } else if (strength == PasswordStrength.STRONG) {
      color = themeColor;
    }

    return color;
  }

  static void onSignedIn() {
    console.wtf('onSignedIn');
    if (authenticated.value) return console.info('cancelled onSignedIn');
    authenticated.value = true;
    Persistence.to.onboarded.val = true;
    AppFunctionsService.to.status(force: true);
    FileService.to.load().then((_) => AppFunctionsService.to.syncUser());
    MainScreenController.to.load();

    // workaround
    if (Get.currentRoute == Routes.welcome) {
      Get.offNamedUntil(Routes.main, (route) => false);
    }
  }

  static void onSignedOut() async {
    console.wtf('onSignedOut');
    authenticated.value = false;
    Persistence.to.onboarded.val = false;
    Get.offNamedUntil(Routes.main, (route) => false);
    AppService.to.reset();
  }

  static void onSuccessfulUpgrade() async {
    console.wtf('onSuccessfulUpgrade');
    AppFunctionsService.to.status(force: true);
    AnalyticsService.to.logEvent('success-upgrade-dialog');
  }

  static void onCancelledUpgradeScreen() {
    console.wtf('onCancelledUpgradeScreen');
  }
}
