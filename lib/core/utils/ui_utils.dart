import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UIUtils {
  static Future<void> showSnackBar({
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

  static Future<void> showSimpleDialog(
    String title,
    String body, {
    String? closeText,
    Function()? action,
    String? actionText,
  }) async {
    final content = SingleChildScrollView(child: Text(body));

    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Utils.isDrawerExpandable
            ? content
            : Container(
                constraints: const BoxConstraints(maxHeight: 600),
                width: 400,
                child: content,
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

  static Future<void> showImageDialog(
    Widget image, {
    required String title,
    String? subTitle,
    required String body,
    Function()? onClose,
    String? closeText,
    Function()? action,
    String? actionText,
    ButtonStyle? actionStyle,
  }) async {
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
                onPressed: onClose ?? Get.back,
                child: Text(closeText ?? 'okay'.tr),
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: action,
                  style: actionStyle,
                  child: Text(actionText ?? 'okay'.tr),
                ),
              ),
            ]
          ],
        ),
      ],
    );

    await Get.dialog(
      AlertDialog(
        title: null,
        actionsAlignment: MainAxisAlignment.center,
        content: Utils.isDrawerExpandable
            ? bodyContent
            : SizedBox(width: 400, child: bodyContent),
      ),
    );
  }

  static Future<void> showQR(
    String data, {
    required String title,
    required String subTitle,
  }) async {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Center(
            child: QrImage(
              data: data,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          subTitle,
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );

    await Get.dialog(AlertDialog(
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: Utils.isDrawerExpandable
          ? content
          : Container(
              constraints: const BoxConstraints(maxHeight: 600),
              width: 450,
              child: content,
            ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('okay'.tr),
        ),
      ],
    ));
  }
}
