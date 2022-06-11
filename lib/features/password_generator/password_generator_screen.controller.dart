import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:random_string_generator/random_string_generator.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';

class PasswordGeneratorScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PasswordGeneratorScreenController(), fenix: true);
  }
}

class PasswordGeneratorScreenController extends GetxController
    with ConsoleMixin {
  static PasswordGeneratorScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final password = ''.obs;
  final length = 15.0.obs;
  final hasLetters = true.obs;
  final hasNumbers = true.obs;
  final hasSymbols = true.obs;

  // PROPERTIES

  // GETTERS
  String get strengthName {
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

  Color get strengthColor {
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

  double get strengthValue =>
      (strength.index.toDouble() + 0.5) / PasswordStrength.STRONG.index;

  PasswordStrength get strength =>
      PasswordStrengthChecker.checkStrength(password.value);

  // INIT
  @override
  void onInit() {
    generate();
    super.onInit();
  }

  // FUNCTIONS
  void generate() {
    try {
      password.value = RandomStringGenerator(
        fixedLength: length.value.toInt(),
        hasAlpha: hasLetters.value,
        hasDigits: hasNumbers.value,
        hasSymbols: hasSymbols.value,
        mustHaveAtLeastOneOfEach: true,
      ).generate();
    } catch (e) {
      console.error('error: $e');
    }
  }

  void copy() {
    Utils.copyToClipboard(password.value);
  }
}
