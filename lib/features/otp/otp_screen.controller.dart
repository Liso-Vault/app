import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp/otp.dart';

class OTPScreenController extends GetxController with ConsoleMixin {
  static OTPScreenController get to => Get.find();

  // VARIABLES
  final codeController = TextEditingController(text: 'JBSWY3DPEHPK3PXP');

  // PROPERTIES
  final code = ''.obs;

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS
  void generate() {
    code.value = OTP
        .generateTOTPCode(
          codeController.text,
          DateTime.now().millisecondsSinceEpoch,
          algorithm: Algorithm.SHA256,
          interval: 10,
          length: 1,
          isGoogle: true,
        )
        .toString();
  }
}
