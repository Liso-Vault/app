import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/resources/resources.dart';

import '../../core/utils/biometric.util.dart';
import 'unlock_screen.controller.dart';

class UnlockScreen extends GetView<UnlockScreenController> with ConsoleMixin {
  const UnlockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(Images.logo, width: 100),
        const SizedBox(height: 20),
        const Text(
          kAppName,
          style: TextStyle(fontSize: 25),
        ),
        const SizedBox(height: 15),
        Text(
          controller.passwordMode
              ? 'Enter your wallet password to proceed'
              : 'Enter the wallet password to unlock $kAppName',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        TextFormField(
          autofocus: true,
          controller: controller.passwordController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          textInputAction: TextInputAction.go,
          onChanged: controller.onChanged,
          onFieldSubmitted: (text) => controller.unlock(),
          decoration: InputDecoration(
            hintText: 'password'.tr,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => TextButton.icon(
                label:
                    Text(controller.passwordMode ? 'proceed'.tr : 'unlock'.tr),
                icon: const Icon(LineIcons.lockOpen),
                onPressed: controller.canProceed() ? controller.unlock : null,
              ),
            ),
            if (BiometricUtils.ready) ...[
              const SizedBox(width: 15),
              IconButton(
                icon: const Icon(LineIcons.fingerprint),
                onPressed: controller.biometricAuthentication,
              ),
            ]
          ],
        ),
        if (!controller.passwordMode) ...[
          const SizedBox(height: 10),
          Obx(
            () => Text(
              '${controller.attemptsLeft()} ' + 'attempts_left'.tr,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ]
      ],
    );

    return WillPopScope(
      onWillPop: () => Future.value(controller.passwordMode),
      child: Scaffold(
        appBar: controller.passwordMode ? AppBar() : null,
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: controller.obx(
                (_) => content,
                onLoading: const BusyIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
