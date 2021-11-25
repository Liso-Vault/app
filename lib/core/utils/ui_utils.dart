import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UIUtils {
  static showSnackBar({
    required String title,
    required String message,
    final Widget? icon,
    final int seconds = 7,
  }) async {
    Get.snackbar(
      title,
      message,
      icon: icon ?? const Icon(Icons.info, size: 25),
      titleText: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(message, style: const TextStyle(fontSize: 14)),
      duration: Duration(seconds: seconds),
      borderRadius: 8,
      backgroundColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.white,
      shouldIconPulse: true,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8.0),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
