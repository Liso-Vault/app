import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/resources/resources.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'console.dart';
import 'globals.dart';

class Utils {
  static final console = Console(name: 'Utils');

  // TODO: improve password validation
  static String? validatePassword(String text) {
    const min = 8;
    const max = 30;

    if (text.isEmpty) {
      return 'Enter your strong password';
    } else if (text.length < min) {
      return 'Vault password must be at least $min characters';
    } else if (text.length > max) {
      return "That's a lot of a password";
    } else {
      return null;
    }
  }

  static String generatePassword({
    bool letter = true,
    bool isNumber = true,
    bool isSpecial = true,
    int length = 15,
  }) {
    const letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
    const letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const number = '0123456789';
    const special = '@#%^*>\$@?/[]=+';

    String chars = "";
    if (letter) chars += ' $letterLowerCase $letterUpperCase ';
    if (isNumber) chars += ' $number ';
    if (isSpecial) chars += ' $special ';

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

  static String originImageParser(String origin) {
    String imagePath = OriginImages.other;

    switch (origin) {
      case 'Metamask':
        imagePath = OriginImages.metamask;
        break;
      case 'TrustWallet':
        imagePath = OriginImages.trustWallet;
        break;
      case 'Exodus':
        imagePath = OriginImages.exodus;
        break;
      case 'MyEtherWallet':
        imagePath = OriginImages.myetherwallet;
        break;
      case 'BitGo':
        imagePath = OriginImages.bitgo;
        break;
      case 'Math Wallet':
        imagePath = OriginImages.mathWallet;
        break;
      case 'Cano':
        imagePath = OriginImages.cano;
        break;
      case 'Syrius':
        imagePath = OriginImages.syrius;
        break;
      default:
    }

    return imagePath;
  }

  static Icon categoryIcon(LisoItemCategory category, {Color? color}) {
    Color _color = Get.theme.primaryColor;
    IconData? _iconData;

    switch (category) {
      case LisoItemCategory.cryptoWallet:
        _iconData = LineIcons.wallet;
        // _color = Colors.green;
        break;
      case LisoItemCategory.login:
        _iconData = LineIcons.desktop;
        // _color = Colors.green;
        break;
      case LisoItemCategory.password:
        _iconData = LineIcons.fingerprint;
        // _color = Colors.green;
        break;
      case LisoItemCategory.identity:
        _iconData = LineIcons.identificationBadge;
        // _color = Colors.green;
        break;
      case LisoItemCategory.note:
        _iconData = LineIcons.stickyNote;
        // _color = Colors.green;
        break;
      case LisoItemCategory.cashCard:
        _iconData = LineIcons.creditCard;
        // _color = Colors.green;
        break;
      case LisoItemCategory.bankAccount:
        _iconData = LineIcons.landmark;
        // _color = Colors.green;
        break;
      case LisoItemCategory.medicalRecord:
        _iconData = LineIcons.medicalFile;
        // _color = Colors.green;
        break;
      case LisoItemCategory.passport:
        _iconData = LineIcons.passport;
        // _color = Colors.green;
        break;
      case LisoItemCategory.server:
        _iconData = LineIcons.server;
        // _color = Colors.green;
        break;
      case LisoItemCategory.softwareLicense:
        _iconData = LineIcons.laptopCode;
        // _color = Colors.green;
        break;
      case LisoItemCategory.apiCredential:
        _iconData = LineIcons.memory;
        // _color = Colors.green;
        break;
      case LisoItemCategory.database:
        _iconData = LineIcons.database;
        // _color = Colors.green;
        break;
      case LisoItemCategory.driversLicense:
        _iconData = LineIcons.car;
        // _color = Colors.green;
        break;
      case LisoItemCategory.email:
        _iconData = LineIcons.envelope;
        // _color = Colors.green;
        break;
      case LisoItemCategory.membership:
        _iconData = LineIcons.identificationCard;
        // _color = Colors.green;
        break;
      case LisoItemCategory.outdoorLicense:
        _iconData = LineIcons.running;
        // _color = Colors.green;
        break;
      case LisoItemCategory.rewardsProgram:
        _iconData = LineIcons.award;
        // _color = Colors.green;
        break;
      case LisoItemCategory.socialSecurity:
        _iconData = LineIcons.moneyBill;
        // _color = Colors.green;
        break;
      case LisoItemCategory.wirelessRouter:
        _iconData = LineIcons.wifi;
        // _color = Colors.green;
        break;
      case LisoItemCategory.encryption:
        _iconData = LineIcons.key;
        // _color = Colors.green;
        break;
      default:
        throw 'item category: $category not found while obtaining icon';
    }

    _color = color ?? _color;

    return Icon(_iconData, color: _color);
  }
}
