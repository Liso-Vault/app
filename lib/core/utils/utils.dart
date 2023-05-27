import 'package:app_core/config.dart';
import 'package:app_core/config/app.model.dart';
import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/license/license.service.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/gradient.widget.dart';
import 'package:app_core/widgets/pro.widget.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:extended_image/extended_image.dart';

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
          onPressed: Get.back,
          child: Text('okay'.tr),
        ),
      ],
    ));
  }

  static Icon categoryIcon(String category, {Color? color, double? size}) {
    IconData? iconData;

    if (category == LisoItemCategory.cryptoWallet.name) {
      iconData = Iconsax.wallet;
      color = Colors.redAccent;
    } else if (category == LisoItemCategory.login.name) {
      iconData = Iconsax.login;
      color = Colors.blueAccent;
    } else if (category == LisoItemCategory.password.name) {
      iconData = Iconsax.password_check;
      color = Colors.teal;
    } else if (category == LisoItemCategory.identity.name) {
      iconData = Iconsax.user;
      color = Colors.purpleAccent;
    } else if (category == LisoItemCategory.note.name) {
      iconData = Iconsax.note_text;
      color = Colors.pinkAccent;
    } else if (category == LisoItemCategory.insurance.name) {
      iconData = Iconsax.shield_tick;
      color = Colors.pinkAccent;
    } else if (category == LisoItemCategory.healthInsurance.name) {
      iconData = Iconsax.health;
      color = Colors.pink;
    } else if (category == LisoItemCategory.cashCard.name) {
      iconData = Iconsax.card;
      color = Colors.deepOrange;
    } else if (category == LisoItemCategory.bankAccount.name) {
      iconData = Iconsax.bank;
      color = Colors.amberAccent;
    } else if (category == LisoItemCategory.medicalRecord.name) {
      iconData = Iconsax.health;
      color = Colors.red;
    } else if (category == LisoItemCategory.passport.name) {
      iconData = Iconsax.airplane_square;
      color = Colors.purple;
    } else if (category == LisoItemCategory.server.name) {
      iconData = Iconsax.cloud;
      color = Colors.blueAccent;
    } else if (category == LisoItemCategory.softwareLicense.name) {
      iconData = Iconsax.code_1;
      color = Colors.indigoAccent;
    } else if (category == LisoItemCategory.apiCredential.name) {
      iconData = Iconsax.code;
      color = Colors.lime;
    } else if (category == LisoItemCategory.database.name) {
      iconData = Iconsax.document;
      color = Colors.orangeAccent;
    } else if (category == LisoItemCategory.driversLicense.name) {
      iconData = Iconsax.car;
      color = Colors.teal;
    } else if (category == LisoItemCategory.email.name) {
      iconData = Iconsax.message;
      color = Colors.green;
    } else if (category == LisoItemCategory.membership.name) {
      iconData = Iconsax.personalcard;
      color = Colors.red;
    } else if (category == LisoItemCategory.outdoorLicense.name) {
      iconData = Iconsax.activity;
      color = Colors.pink;
    } else if (category == LisoItemCategory.rewardsProgram.name) {
      iconData = Iconsax.award;
      color = Colors.amber;
    } else if (category == LisoItemCategory.socialSecurity.name) {
      iconData = Iconsax.security_card;
      color = Colors.blue;
    } else if (category == LisoItemCategory.wirelessRouter.name) {
      iconData = Iconsax.home_wifi;
      color = Colors.green;
    } else if (category == LisoItemCategory.encryption.name) {
      iconData = Iconsax.key;
    } else if (category == LisoItemCategory.otp.name) {
      iconData = LineIcons.mobilePhone;
      color = Colors.deepPurple;
    } else if (category == LisoItemCategory.custom.name) {
      iconData = Iconsax.category;
    } else {
      iconData = Iconsax.category;
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
    if (!object.isFile) return const Icon(Iconsax.folder_open5);
    var iconData = Iconsax.document_1;
    if (object.fileType == null) return Icon(iconData);

    switch (object.fileType!) {
      case 'liso':
        return RemoteImage(
          url: 'https://i.imgur.com/GW4HQ1r.png',
          height: 25,
          placeholder: Image.asset(Images.logo, height: 25),
        );
      case 'image':
        iconData = Iconsax.gallery;
        break;
      case 'video':
        iconData = Iconsax.play;
        break;
      case 'archive':
        iconData = Iconsax.archive;
        break;
      case 'audio':
        iconData = Iconsax.music;
        break;
      case 'code':
        iconData = Icons.code;
        break;
      case 'book':
        iconData = Iconsax.book_1;
        break;
      case 'exec':
        iconData = Iconsax.code;
        break;
      case 'web':
        iconData = Iconsax.chrome;
        break;
      case 'sheet':
        iconData = Iconsax.document_text;
        break;
      case 'text':
        iconData = Iconsax.document;
        break;
      case 'font':
        iconData = Iconsax.text_block;
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
    String name = 'Very Weak'; // VERY WEAK

    if (strength == PasswordStrength.WEAK) {
      name = 'Weak';
    } else if (strength == PasswordStrength.GOOD) {
      name = 'Good';
    } else if (strength == PasswordStrength.STRONG) {
      name = 'Strong';
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
    authenticated.value = true;

    AppFunctionsService.to.status(force: true).then((value) {
      // manually prevent duplicates becaused onSignedIn is fired twice
      if (!LicenseService.to.isPremium && !isBeta) {
        Utils.adaptiveRouteOpen(name: Routes.upgrade);
        // AppodealService.to.init();
      }
    });

    if (Get.currentRoute != Routes.main) {
      console.wtf('Routes.main onSignedIn()');
      Get.offNamedUntil(Routes.main, (route) => false);
    }

    StorageService.to.load().then((_) => AppFunctionsService.to.syncUser());
  }

  static void onSignedOut() {
    console.wtf('onSignedOut');
    authenticated.value = false;
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
    // if (kDebugMode) return;

    final bodyContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ExtendedImage.network(
            kGiveawayImageUrl,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 30),
        const PremiumCard(size: 25, text: 'FREE PREMIUM'),
        const SizedBox(height: 10),
        Text('giveaway_message'.tr, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        GradientWidget(
          gradient: LinearGradient(colors: CoreConfig().gradientColors),
          child: Text(
            'giveaway_highlight'.tr,
            style: const TextStyle(fontSize: 15, color: Colors.green),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: Get.back,
                child: Text('close'.tr),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Utils.openUrl(appConfig.links.giveaway),
                child: Text('learn_more'.tr),
              ),
            ),
          ],
        )
      ],
    );

    Get.dialog(
      AlertDialog(
        title: null,
        actionsAlignment: MainAxisAlignment.center,
        content: isSmallScreen
            ? bodyContent
            : SizedBox(width: 400, child: bodyContent),
      ),
    );

    AnalyticsService.to.logEvent('cancelled-upgrade-dialog');
  }

  static void fallbackUpgrade() {
    final bodyContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ExtendedImage.network(
            kGiveawayImageUrl,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${'free'.tr.toUpperCase()} ',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Get.theme.primaryColor,
              ),
            ),
            ProText(
              size: 25,
              text: 'premium'.tr.toUpperCase(),
            )
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'giveaway_message'.tr,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        GradientWidget(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 247, 0),
              Color.fromARGB(255, 255, 0, 225),
            ],
          ),
          child: Text(
            'giveaway_highlight'.tr,
            style: const TextStyle(fontSize: 15, color: Colors.green),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        // TextButton.icon(
        //   onPressed: () => Utils.openUrl(giveaway.detailsUrl),
        //   label: const Text('Learn more'),
        //   icon: const Icon(Iconsax.book_1),
        // ),
        // const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: Get.back,
                child: Text('close'.tr),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Utils.openUrl(
                  appConfig.links.giveaway,
                ),
                child: Text('learn_more'.tr),
              ),
            ),
          ],
        )
      ],
    );

    Get.dialog(
      AlertDialog(
        title: null,
        actionsAlignment: MainAxisAlignment.center,
        content: isSmallScreen
            ? bodyContent
            : SizedBox(width: 400, child: bodyContent),
      ),
    );

    AnalyticsService.to.logEvent('fallback-dialog');
  }
}
