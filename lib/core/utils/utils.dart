import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/pages.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:window_manager/window_manager.dart';

import '../services/persistence.service.dart';
import 'console.dart';
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
    final _locale =
        (Get.locale?.languageCode ?? 'en_US') + (short ? "_short" : "");
    return timeago.format(dateTime, locale: _locale).replaceFirst("~", "");
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
    console.wtf('setSize');
    windowManager.setSize(Size(
      persistence.windowWidth.val,
      persistence.windowHeight.val,
    ));

    console.wtf('done');
  }

  static Icon categoryIcon(LisoItemCategory category, {Color? color}) {
    IconData? _iconData;

    switch (category) {
      case LisoItemCategory.cryptoWallet:
        _iconData = LineIcons.wallet;
        break;
      case LisoItemCategory.login:
        _iconData = LineIcons.desktop;
        break;
      case LisoItemCategory.password:
        _iconData = LineIcons.fingerprint;
        break;
      case LisoItemCategory.identity:
        _iconData = LineIcons.identificationBadge;
        break;
      case LisoItemCategory.note:
        _iconData = LineIcons.stickyNote;
        break;
      case LisoItemCategory.cashCard:
        _iconData = LineIcons.creditCard;
        break;
      case LisoItemCategory.bankAccount:
        _iconData = LineIcons.landmark;
        break;
      case LisoItemCategory.medicalRecord:
        _iconData = LineIcons.medicalFile;
        break;
      case LisoItemCategory.passport:
        _iconData = LineIcons.passport;
        break;
      case LisoItemCategory.server:
        _iconData = LineIcons.server;
        break;
      case LisoItemCategory.softwareLicense:
        _iconData = LineIcons.laptopCode;
        break;
      case LisoItemCategory.apiCredential:
        _iconData = LineIcons.memory;
        break;
      case LisoItemCategory.database:
        _iconData = LineIcons.database;
        break;
      case LisoItemCategory.driversLicense:
        _iconData = LineIcons.car;
        break;
      case LisoItemCategory.email:
        _iconData = LineIcons.envelope;
        break;
      case LisoItemCategory.membership:
        _iconData = LineIcons.identificationCard;
        break;
      case LisoItemCategory.outdoorLicense:
        _iconData = LineIcons.running;
        break;
      case LisoItemCategory.rewardsProgram:
        _iconData = LineIcons.award;
        break;
      case LisoItemCategory.socialSecurity:
        _iconData = LineIcons.moneyBill;
        break;
      case LisoItemCategory.wirelessRouter:
        _iconData = LineIcons.wifi;
        break;
      case LisoItemCategory.encryption:
        _iconData = LineIcons.key;
        break;
      default:
        _iconData = LineIcons.exclamationCircle; // not found
        break;
    }

    return Icon(_iconData, color: color);
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
      return 'Enter your strong password';
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
}
