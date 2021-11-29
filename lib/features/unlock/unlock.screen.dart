import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/resources/resources.dart';

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
          'Unlock Vault',
          style: TextStyle(fontSize: 25),
        ),
        const SizedBox(height: 15),
        const Text(
          'Enter the password to decrypt and access the local vault file',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: controller.passwordController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: controller.onChanged,
          onFieldSubmitted: (text) => controller.unlock(),
          decoration: Styles.inputDecoration.copyWith(
            hintText: 'Vault Password',
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => TextButton.icon(
            label: const Text('Unlock'),
            icon: const Icon(LineIcons.lockOpen),
            onPressed: controller.canProceed() ? controller.unlock : null,
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            '${controller.attemptsLeft()} attempts left',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Container(
              constraints: Styles.containerConstraints,
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
