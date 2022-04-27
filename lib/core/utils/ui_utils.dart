import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/utils.dart';

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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      maxWidth: 500,
      messageText: Text(message, style: const TextStyle(fontSize: 14)),
      duration: Duration(seconds: seconds),
      borderRadius: 8,
      shouldIconPulse: true,
      margin: const EdgeInsets.all(8),
      snackPosition:
          Utils.isDrawerExpandable ? SnackPosition.BOTTOM : SnackPosition.TOP,
    );
  }

  static void showSimpleDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Utils.isDrawerExpandable
            ? Text(message)
            : SizedBox(
                width: 600,
                child: Text(message),
              ),
        actions: [
          TextButton(
            child: Text('okay'.tr),
            onPressed: Get.back,
          ),
        ],
      ),
    );
  }
}
