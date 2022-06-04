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

  static void showSimpleDialog(
    String title,
    String body, {
    String? closeText,
    Function()? action,
    String? actionText,
  }) {
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
            child: Text(closeText ?? 'okay'.tr),
          ),
          if (action != null) ...[
            TextButton(
              onPressed: action,
              child: Text(actionText ?? 'okay'.tr),
            ),
          ]
        ],
      ),
    );
  }

  static void showImageDialog(
    Widget image, {
    required String title,
    String? subTitle,
    required String body,
    String? closeText,
    Function()? action,
    String? actionText,
  }) {
    final bodyContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        image,
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(fontSize: 25),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        if (subTitle != null) ...[
          Text(
            subTitle,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
        Text(body, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: Get.back,
                child: Text(closeText ?? 'okay'.tr),
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: action,
                  child: Text(actionText ?? 'okay'.tr),
                ),
              ),
            ]
          ],
        ),
      ],
    );

    Get.dialog(
      AlertDialog(
        title: null,
        actionsAlignment: MainAxisAlignment.center,
        content: Utils.isDrawerExpandable
            ? bodyContent
            : SizedBox(width: 400, child: bodyContent),
      ),
    );
  }
}
