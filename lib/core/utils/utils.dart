import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/pages.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';

import '../../features/general/remote_image.widget.dart';
import '../../features/pro/pro.controller.dart';
import '../../features/files/model/s3_content.model.dart';
import '../../resources/resources.dart';
import '../firebase/auth.service.dart';
import '../firebase/config/config.service.dart';
import '../persistence/persistence.dart';
import 'globals.dart';

class Utils {
  // VARIABLES
  static final console = Console(name: 'Utils');

  // GETTERS
  static bool get isDrawerExpandable =>
      Get.mediaQuery.size.width < kDesktopChangePoint;

  // FUNCTIONS

  static void copyToClipboard(text) async {
    await Clipboard.setData(ClipboardData(text: text));
    // TODO: localize
    UIUtils.showSnackBar(
      title: 'Copied',
      message: 'Successfully copied to clipboard',
      icon: const Icon(LineIcons.copy),
      seconds: 4,
    );
  }

  static String timeAgo(DateTime dateTime, {bool short = true}) {
    final locale =
        (Get.locale?.languageCode ?? 'en_US') + (short ? "_short" : "");
    return timeago.format(dateTime, locale: locale).replaceFirst("~", "");
  }

  // support higher refresh rate
  static void setDisplayMode() async {
    if (!GetPlatform.isAndroid) return;

    try {
      final mode = await FlutterDisplayMode.active;
      console.warning('active mode: $mode');
      final modes = await FlutterDisplayMode.supported;

      for (DisplayMode e in modes) {
        console.info('display modes: $e');
      }

      await FlutterDisplayMode.setPreferredMode(modes.last);
      console.info('set mode: ${modes.last}');
    } on PlatformException catch (e) {
      console.error('display mode error: $e');
    }
  }

  static Future<void> setWindowSize() async {
    await windowManager.setMinimumSize(kMinWindowSize);
    final persistence = Persistence.to;

    // set preferred size
    windowManager.setSize(Size(
      persistence.windowWidth.val,
      persistence.windowHeight.val,
    ));
  }

  static Icon categoryIcon(String category, {Color? color, double? size}) {
    IconData? iconData;

    if (category == LisoItemCategory.cryptoWallet.name) {
      iconData = Iconsax.wallet;
    } else if (category == LisoItemCategory.login.name) {
      iconData = Iconsax.login;
    } else if (category == LisoItemCategory.password.name) {
      iconData = Iconsax.password_check;
    } else if (category == LisoItemCategory.identity.name) {
      iconData = Iconsax.user;
    } else if (category == LisoItemCategory.note.name) {
      iconData = Iconsax.note_text;
    } else if (category == LisoItemCategory.insurance.name) {
      iconData = Iconsax.shield_tick;
    } else if (category == LisoItemCategory.healthInsurance.name) {
      iconData = Iconsax.health;
    } else if (category == LisoItemCategory.cashCard.name) {
      iconData = Iconsax.card;
    } else if (category == LisoItemCategory.bankAccount.name) {
      iconData = Iconsax.bank;
    } else if (category == LisoItemCategory.medicalRecord.name) {
      iconData = Iconsax.health;
    } else if (category == LisoItemCategory.passport.name) {
      iconData = Iconsax.airplane_square;
    } else if (category == LisoItemCategory.server.name) {
      iconData = Iconsax.cloud;
    } else if (category == LisoItemCategory.softwareLicense.name) {
      iconData = Iconsax.code_1;
    } else if (category == LisoItemCategory.apiCredential.name) {
      iconData = Iconsax.code;
    } else if (category == LisoItemCategory.database.name) {
      iconData = Iconsax.document;
    } else if (category == LisoItemCategory.driversLicense.name) {
      iconData = Iconsax.car;
    } else if (category == LisoItemCategory.email.name) {
      iconData = Iconsax.message;
    } else if (category == LisoItemCategory.membership.name) {
      iconData = Iconsax.personalcard;
    } else if (category == LisoItemCategory.outdoorLicense.name) {
      iconData = Iconsax.activity;
    } else if (category == LisoItemCategory.rewardsProgram.name) {
      iconData = Iconsax.award;
    } else if (category == LisoItemCategory.socialSecurity.name) {
      iconData = Iconsax.security_card;
    } else if (category == LisoItemCategory.wirelessRouter.name) {
      iconData = Iconsax.home_wifi;
    } else if (category == LisoItemCategory.encryption.name) {
      iconData = Iconsax.key;
    } else if (category == LisoItemCategory.otp.name) {
      iconData = LineIcons.mobilePhone;
    } else if (category == LisoItemCategory.custom.name) {
      iconData = Iconsax.category;
    } else {
      iconData = Iconsax.category;
    }

    return Icon(iconData, color: color, size: size);
  }

  static Future<dynamic>? adaptiveRouteOpen({
    required String name,
    String method = 'toNamed',
    Map<String, String> parameters = const {},
    dynamic arguments,
  }) {
    // Regular navigation for mobile
    if (isDrawerExpandable) {
      switch (method) {
        case 'toNamed':
          return Get.toNamed(
            name,
            parameters: parameters,
            arguments: arguments,
          );
        case 'offAndToNamed':
          return Get.offAndToNamed(
            name,
            parameters: parameters,
            arguments: arguments,
          );
        case 'offAllNamed':
          return Get.offAllNamed(
            name,
            parameters: parameters,
            arguments: arguments,
          );
        default:
      }
    }

    // Open page as dialog for desktop
    Get.parameters = parameters; // manually pass parameters
    final page = AppPages.routes.firstWhere((e) => e.name == name).page();
    // larger real estate for secure notes
    final isNote = parameters['category'] == LisoItemCategory.note.name;

    final dialog = Dialog(
      child: SizedBox(
        width: isNote ? 800 : 600,
        height: isNote ? 1100 : 900,
        child: page,
      ),
    );

    return Get.dialog(
      dialog,
      routeSettings: RouteSettings(name: name, arguments: arguments),
    );
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

  static Widget s3ContentIcon(S3Content content) {
    if (!content.isFile) return const Icon(Iconsax.folder_open5);
    var iconData = Iconsax.document_1;
    if (content.fileType == null) return Icon(iconData);

    switch (content.fileType!) {
      case 'liso':
        return RemoteImage(
          url: ConfigService.to.general.app.image,
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

  static String platformName() {
    if (GetPlatform.isAndroid) {
      return "android";
    } else if (GetPlatform.isIOS) {
      return "ios";
    } else if (GetPlatform.isWindows) {
      return "windows";
    } else if (GetPlatform.isMacOS) {
      return "macos";
    } else if (GetPlatform.isLinux) {
      return "linux";
    } else if (GetPlatform.isFuchsia) {
      return "fuchsia";
    } else {
      return "unknown";
    }
  }

  static void contactEmail({
    required String subject,
    required String preBody,
    required double rating,
    required String previousRoute,
  }) async {
    String ratingEmojis = '';

    for (var i = 0; i < rating.toInt(); i++) {
      ratingEmojis += '✩';
    }

    String body = '$preBody\n\n';

    if (AuthService.to.isSignedIn) {
      body += 'Rating: $ratingEmojis\n';
      body +=
          'User ID: ${AuthService.to.userId}\nAddress: ${Persistence.to.walletAddress.val}\n';
      body += 'RC User ID: ${ProController.to.info.value.originalAppUserId}\n';
      body += 'Entitlement: ${ProController.to.limits.id}\n';
      body += 'Pro: ${ProController.to.isPro}\n';
    }

    body += 'App Version: ${Globals.metadata?.app.formattedVersion}\n';
    body += 'Platform: ${Utils.platformName()}\n';
    body += 'Route: $previousRoute\n';

    final url =
        'mailto:${ConfigService.to.general.app.emails.support}?subject=$subject&body=$body';
    openUrl(Uri.encodeFull(url));
  }

  static Future<void> openUrl(
    String url, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    console.info('launching: $url');
    final canLaunch = await canLaunchUrlString(url);
    if (!canLaunch) console.error('cannot launch');
    launchUrlString(url, mode: mode);
  }
}
