import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:app_core/widgets/logo.widget.dart';
import 'package:app_core/widgets/version.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/persistence/persistence.secret.dart';
import '../../core/utils/utils.dart';
import 'unlock_screen.controller.dart';

class UnlockScreen extends StatelessWidget with ConsoleMixin {
  const UnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnlockScreenController());

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LogoWidget(size: 100),
        const SizedBox(height: 20),
        Text(
          metadataApp.appName,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (!controller.canPop) ...[
          const SizedBox(height: 20),
          Text(
            SecretPersistence.to.shortAddress,
            style: const TextStyle(color: Colors.grey),
          ),
          // const Divider(),
        ],
        if (isLocalAuthSupported) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: controller.authenticate,
              label: Text('authenticate'.tr),
              icon: Icon(
                controller.canPop
                    ? Iconsax.arrow_circle_right_outline
                    : LineAwesome.lock_open_solid,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 20),
          Obx(
            () => TextFormField(
              autofocus: true,
              controller: controller.passwordController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              obscureText: controller.obscurePassword(),
              textInputAction: TextInputAction.go,
              onChanged: controller.onChanged,
              onFieldSubmitted: (text) => controller.unlock(),
              validator: AppUtils.validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                hintText: 'master_password'.tr,
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
          const SizedBox(height: 20),
          Obx(
            () => ElevatedButton.icon(
              label: Text(controller.canPop ? 'proceed'.tr : 'unlock'.tr),
              icon: Icon(
                controller.canPop
                    ? Iconsax.arrow_circle_right_outline
                    : LineAwesome.lock_open_solid,
              ),
              onPressed: controller.canProceed() ? controller.unlock : null,
            ),
          ),
        ]
      ],
    );

    return PopScope(
      canPop: controller.canPop || isAutofill,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: controller.canPop,
          actions: [
            TextButton(
              onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
              child: Text('need_help'.tr),
            ),
          ],
        ),
        bottomNavigationBar: const VersionText(),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: controller.obx(
              (_) => content,
              onLoading: const BusyIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
