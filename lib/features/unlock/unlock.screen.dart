import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

import 'unlock_screen.controller.dart';

class UnlockScreen extends GetView<UnlockScreenController> with ConsoleMixin {
  const UnlockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final importMode = Get.parameters['file_path'] != null;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          importMode ? LineIcons.alternateShield : LineIcons.lock,
          size: 100,
        ),
        const SizedBox(height: 20),
        Text(
          importMode ? 'Unlock Vault' : 'Welcome Back',
          style: const TextStyle(fontSize: 20),
        ),
        if (importMode) ...[
          const SizedBox(height: 15),
          Text(
            Get.parameters['file_path']!,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 15),
        const Text(
          'Enter the password to access the vault',
          style: TextStyle(color: Colors.grey),
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
          validator: (text) => Utils.validatePassword(text!),
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
        if (!importMode) ...[
          const SizedBox(height: 10),
          Obx(
            () => Text(
              '${controller.attemptsLeft()} attempts left',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ]
      ],
    );

    return WillPopScope(
      onWillPop: () => Future.value(importMode),
      child: Scaffold(
        appBar: importMode ? AppBar(title: const Text('Unlock Vault')) : null,
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
