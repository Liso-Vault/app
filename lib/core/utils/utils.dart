import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/pages.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:window_manager/window_manager.dart';

import '../../features/s3/model/s3_content.model.dart';
import '../services/persistence.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'globals.dart';

class Utils {
  // VARIABLES
  static final console = Console(name: 'Utils');

  // GETTERS
  static bool get isDrawerExpandable =>
      Get.mediaQuery.size.width < kDesktopChangePoint;

  // FUNCTIONS

  static String generatePassword({
    bool letter = true,
    bool number = true,
    bool special = true,
    int length = 15,
  }) {
    const lettersLowerCase = "abcdefghijklmnopqrstuvwxyz";
    const lettersUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numbers = '0123456789';
    const specials = '@#%^*>\$@?/[]=+';

    String chars = "";
    if (letter) chars += ' $lettersLowerCase $lettersUpperCase ';
    if (number) chars += ' $numbers ';
    if (special) chars += ' $specials ';

    return List.generate(length, (index) {
      final indexRandom = Random.secure().nextInt(chars.length);
      return chars[indexRandom];
    }).join('');
  }

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
    if (!GetPlatform.isDesktop || GetPlatform.isWeb) return;
    await windowManager.setMinimumSize(kMinWindowSize);
    final persistence = PersistenceService.to;

    // set preferred size
    windowManager.setSize(Size(
      persistence.windowWidth.val,
      persistence.windowHeight.val,
    ));
  }

  static Icon categoryIcon(LisoItemCategory category, {Color? color}) {
    IconData? iconData;

    switch (category) {
      case LisoItemCategory.cryptoWallet:
        iconData = Iconsax.wallet;
        break;
      case LisoItemCategory.login:
        iconData = Iconsax.login;
        break;
      case LisoItemCategory.password:
        iconData = Iconsax.password_check;
        break;
      case LisoItemCategory.identity:
        iconData = Iconsax.user;
        break;
      case LisoItemCategory.note:
        iconData = Iconsax.note_text;
        break;
      case LisoItemCategory.cashCard:
        iconData = Iconsax.card;
        break;
      case LisoItemCategory.bankAccount:
        iconData = Iconsax.bank;
        break;
      case LisoItemCategory.medicalRecord:
        iconData = Iconsax.health;
        break;
      case LisoItemCategory.passport:
        iconData = Iconsax.airplane_square;
        break;
      case LisoItemCategory.server:
        iconData = Iconsax.cloud;
        break;
      case LisoItemCategory.softwareLicense:
        iconData = Iconsax.code_1;
        break;
      case LisoItemCategory.apiCredential:
        iconData = Iconsax.code;
        break;
      case LisoItemCategory.database:
        iconData = Iconsax.document;
        break;
      case LisoItemCategory.driversLicense:
        iconData = Iconsax.car;
        break;
      case LisoItemCategory.email:
        iconData = Iconsax.message;
        break;
      case LisoItemCategory.membership:
        iconData = Iconsax.personalcard;
        break;
      case LisoItemCategory.outdoorLicense:
        iconData = Iconsax.activity;
        break;
      case LisoItemCategory.rewardsProgram:
        iconData = Iconsax.award;
        break;
      case LisoItemCategory.socialSecurity:
        iconData = Iconsax.security_card;
        break;
      case LisoItemCategory.wirelessRouter:
        iconData = Iconsax.home_wifi;
        break;
      case LisoItemCategory.encryption:
        iconData = Iconsax.key;
        break;
      default:
        iconData = Iconsax.warning_2; // not found
        break;
    }

    return Icon(iconData, color: color);
  }

  static Future<dynamic>? adaptiveRouteOpen({
    required String name,
    String method = 'toNamed',
    Map<String, String> parameters = const {},
  }) {
    // Regular navigation for mobile
    if (isDrawerExpandable) {
      switch (method) {
        case 'toNamed':
          return Get.toNamed(name, parameters: parameters);
        case 'offAndToNamed':
          return Get.offAndToNamed(name, parameters: parameters);
        default:
      }
    }

    // Open page as dialog for desktop
    Get.parameters = parameters; // manually pass parameters
    final page = AppPages.routes.firstWhere((e) => e.name == name).page();
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
      routeSettings: RouteSettings(name: name),
    );
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
    } else {
      final hasUppercase = text.contains(RegExp(r'[A-Z]'));
      final hasLowercase = text.contains(RegExp(r'[a-z]'));
      final hasDigits = text.contains(RegExp(r'[0-9]'));
      final hasSpecialCharacters =
          text.contains(RegExp(r'[!;*_=@#$%^&*(),.?":{}[]|<>]'));

      if (!hasUppercase ||
          !hasLowercase ||
          !hasDigits ||
          !hasSpecialCharacters) {
        return 'Must contain a digit, special character, lower and uppercase letters';
      } else {
        return null;
      }
    }
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
}
