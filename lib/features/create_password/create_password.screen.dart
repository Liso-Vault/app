import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icon.dart';
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
          LineIcon(Iconsax.password_check, size: 100, color: kAppColor),
          const SizedBox(height: 20),
          Text(
            'master_password'.tr,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 15),
          const Text(
            "This will be the password to unlock the wallet which also secures the vault.$kVaultExtension with the private key",
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
              validator: Utils.validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: 'password'.tr,
                suffixIcon: IconButton(
                  padding: const EdgeInsets.only(right: 10),
                  onPressed: controller.obscurePassword.toggle,
                  icon: Icon(
                    controller.obscurePassword()
                        ? Iconsax.eye
                        : Iconsax.eye_slash,
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
              onFieldSubmitted: (text) => controller.confirm(),
              validator: Utils.validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: 'confirm_password'.tr,
                suffixIcon: IconButton(
                  padding: const EdgeInsets.only(right: 10),
                  onPressed: controller.obscureConfirmPassword.toggle,
                  icon: Icon(
                    controller.obscureConfirmPassword()
                        ? Iconsax.eye
                        : Iconsax.eye_slash,
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
                icon: const Icon(Iconsax.arrow_circle_right),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: controller.generate,
                label: Text('generate'.tr),
                icon: const Icon(Iconsax.chart_3),
              ),
            ],
          )
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: Center(
          child: Container(
            constraints: Styles.containerConstraints,
            padding: const EdgeInsets.all(30),
            child: controller.obx(
              (_) => SingleChildScrollView(child: content),
              onLoading: const BusyIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
