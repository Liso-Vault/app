import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';

import 'unlock_screen.controller.dart';

class UnlockScreen extends GetView<UnlockScreenController> with ConsoleMixin {
  const UnlockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LineIcons.lock, size: 100),
        const SizedBox(height: 20),
        const Text(
          'Welcome Back',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
        const Text(
          'Enter the password to access the vault',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: controller.passwordController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: controller.onChanged,
          onSubmitted: (text) => controller.unlock(),
          decoration: Styles.inputDecoration.copyWith(
            hintText: 'Current Password',
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
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
