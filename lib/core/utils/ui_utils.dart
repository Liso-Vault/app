import 'package:app_review/app_review.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../features/pro/pro.controller.dart';
import '../../features/supabase/supabase_database.service.dart';
import '../../features/supabase/supabase_functions.service.dart';
import '../firebase/config/config.service.dart';
import '../notifications/notifications.manager.dart';

class UIUtils {
  static final console = Console(name: 'UIUtils');

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
          Utils.isSmallScreen ? SnackPosition.BOTTOM : SnackPosition.TOP,
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
        content: Utils.isSmallScreen
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
        content: Utils.isSmallScreen
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
      content: Utils.isSmallScreen
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

  static void rateAndReview() async {
    final store = ConfigService.to.general.app.links.store;
    final available = await AppReview.isRequestReviewAvailable;
    console.info('review available: $available');

    if (GetPlatform.isAndroid) {
      if (available) {
        final result = await AppReview.openAndroidReview();
        console.info('review result: $result');
      } else {
        Utils.openUrl(store.google);
      }
    } else if (GetPlatform.isIOS) {
      if (available) {
        final result = await AppReview.openIosReview();
        console.info('review result: $result');
      } else {
        Utils.openUrl(store.apple);
      }
    } else if (GetPlatform.isMacOS) {
      Utils.openUrl(store.apple);
    }
  }

  static Future<void> setLicenseKey() async {
    final formKey = GlobalKey<FormState>();
    final keyController = TextEditingController();
    final busy = false.obs;

    void submit() async {
      if (!formKey.currentState!.validate()) return;
      busy.value = true;
      final key = keyController.text.trim();
      final verifyResult = await SupabaseFunctionsService.to.verifyGumroad(
        key,
        updateEntitlement: false,
      );

      verifyResult.fold(
        (left) {
          return UIUtils.showSimpleDialog(
            'Failed Verifying',
            left,
          );
        },
        (right) async {
          if (!right.entitled) {
            return UIUtils.showSimpleDialog(
              'Deactivated License',
              'We are sorry to inform you that your license key is not active anymore.',
            );
          }

          final updateResult = await SupabaseDBService.to.updateLicenseKey(key);

          updateResult.fold(
            (left) => UIUtils.showSimpleDialog(
              'Failed Updating',
              left,
            ),
            (right) {
              Get.back();

              ProController.to.licenseKey.value = right.gumroadLicenseKey;
              ProController.to.verifiedPro.value = true;

              NotificationsManager.notify(
                title: 'License Key Updated',
                body:
                    'Thanks for subscribing to ${ConfigService.to.appName} Pro 🎉',
              );
            },
          );
        },
      );

      busy.value = false;
    }

    final content = Obx(
      () => TextFormField(
        enabled: !busy.value,
        controller: keyController,
        autofocus: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (data) =>
            data!.length != 35 ? 'Please a valid license key' : null,
        decoration: const InputDecoration(
          labelText: 'License Key',
          hintText: 'Gumroad License Key',
        ),
      ),
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Update License Key'), // TODO: localize
        content: Form(
          key: formKey,
          child: Utils.isSmallScreen
              ? content
              : SizedBox(width: 450, child: content),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          Obx(
            () => Visibility(
              visible: !busy.value,
              replacement: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
              child: TextButton(
                onPressed: submit,
                child: const Text('Update'), // TODO: localize
              ),
            ),
          ),
        ],
      ),
    );
  }
}
