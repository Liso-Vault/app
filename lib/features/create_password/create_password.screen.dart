import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';

import '../../core/utils/globals.dart';
import 'create_password_screen.controller.dart';

class CreatePasswordScreen extends GetView<CreatePasswordScreenController>
    with ConsoleMixin {
  const CreatePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LineIcon(
            LineIcons.alternateShield,
            size: 100,
            color: kAppColor,
          ),
          const SizedBox(height: 20),
          Text(
            'vault_password'.tr,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 15),
          const Text(
            'This will be the password to encrypt and access the local vault file',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Obx(
            () => TextFormField(
              autofocus: true,
              controller: controller.passwordController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              obscureText: controller.obscurePassword(),
              textInputAction: TextInputAction.next,
              validator: (text) => Utils.validatePassword(text!),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: Styles.inputDecoration.copyWith(
                hintText: 'password'.tr,
                suffixIcon: IconButton(
                  onPressed: controller.obscurePassword.toggle,
                  icon: Icon(
                    controller.obscurePassword()
                        ? LineIcons.eye
                        : LineIcons.eyeSlash,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => TextFormField(
              controller: controller.passwordConfirmController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              obscureText: controller.obscureConfirmPassword(),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (text) => controller.confirm,
              validator: (text) => Utils.validatePassword(text!),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: Styles.inputDecoration.copyWith(
                hintText: 'confirm_password'.tr,
                suffixIcon: IconButton(
                  onPressed: controller.obscureConfirmPassword.toggle,
                  icon: Icon(
                    controller.obscureConfirmPassword()
                        ? LineIcons.eye
                        : LineIcons.eyeSlash,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Use a password that has at least 8 characters, one uppercase letter, one lowercase letter, and one symbol',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: controller.confirm,
                label: Text('confirm'.tr),
                icon: const Icon(LineIcons.check),
                style: Styles.elevatedButtonStyle,
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: controller.generate,
                label: Text('generate'.tr),
                icon: const Icon(LineIcons.flask),
              ),
            ],
          )
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        // appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Container(
              constraints: Styles.containerConstraints,
              child: controller.obx(
                (_) => SingleChildScrollView(child: content),
                onLoading: const BusyIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
