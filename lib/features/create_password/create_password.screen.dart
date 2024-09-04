import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:liso/core/utils/styles.dart';
import 'package:liso/core/utils/utils.dart';

import '../../core/utils/globals.dart';
import 'create_password_screen.controller.dart';

class CreatePasswordScreen extends StatelessWidget with ConsoleMixin {
  const CreatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePasswordScreenController());

    final content = Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.password_check_outline, size: 150, color: themeColor),
          const SizedBox(height: 20),
          Text(
            'master_password'.tr,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "This will be the password to unlock the wallet which also secures the vault.$kVaultExtension with the private key",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Obx(
            () => TextFormField(
              autofocus: true,
              controller: controller.passwordController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              obscureText: controller.obscurePassword(),
              textInputAction: TextInputAction.next,
              validator: AppUtils.validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                hintText: 'password'.tr,
                suffixIcon: IconButton(
                  padding: const EdgeInsets.only(right: 10),
                  onPressed: controller.obscurePassword.toggle,
                  icon: Icon(
                    controller.obscurePassword()
                        ? Iconsax.eye_outline
                        : Iconsax.eye_slash_outline,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Obx(
            () => TextFormField(
              controller: controller.passwordConfirmController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              obscureText: controller.obscureConfirmPassword(),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (text) => controller.confirm(),
              validator: AppUtils.validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                hintText: 'confirm_password'.tr,
                suffixIcon: IconButton(
                  padding: const EdgeInsets.only(right: 10),
                  onPressed: controller.obscureConfirmPassword.toggle,
                  icon: Icon(
                    controller.obscureConfirmPassword()
                        ? Iconsax.eye_outline
                        : Iconsax.eye_slash_outline,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: controller.confirm,
                label: Text('confirm'.tr),
                icon: const Icon(Iconsax.arrow_circle_right_outline),
              ),
              const SizedBox(height: 15),
              TextButton.icon(
                onPressed: controller.generate,
                label: Text('generate'.tr),
                icon: const Icon(Iconsax.chart_3_outline),
              ),
            ],
          )
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLeadingButton(),
        actions: [
          TextButton(
            onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
            child: const Text('Need Help ?'),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: Styles.containerConstraints,
          child: controller.obx(
            (_) => SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: content,
            ),
            onLoading: const BusyIndicator(),
          ),
        ),
      ),
    );
  }
}
