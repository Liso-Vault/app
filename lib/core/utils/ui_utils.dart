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

  static void showSimpleDialog(String title, String body) {
    final bodyContent = Text(body);

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Utils.isDrawerExpandable
            ? bodyContent
            : SizedBox(
                width: 400,
                child: bodyContent,
              ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('okay'.tr),
          ),
        ],
      ),
    );
  }

  static void showImageDialog(
    Widget image, {
    required String title,
    required String body,
    String? closeText,
    Function()? action,
    String? actionText,
  }) {
    final bodyContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        image,
        const SizedBox(height: 30),
        Text(title, style: const TextStyle(fontSize: 25)),
        const SizedBox(height: 10),
        Text(body, textAlign: TextAlign.center),
      ],
    );

    Get.dialog(
      AlertDialog(
        title: null,
        actionsAlignment: MainAxisAlignment.center,
        content: Utils.isDrawerExpandable
            ? bodyContent
            : SizedBox(
                width: 400,
                child: bodyContent,
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: action ?? Get.back,
                child: Text(actionText ?? 'okay'.tr),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
