import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/version.widget.dart';
import 'package:liso/resources/resources.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/utils.dart';
import '../general/remote_image.widget.dart';
import 'unlock_screen.controller.dart';

class UnlockScreen extends StatelessWidget with ConsoleMixin {
  const UnlockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnlockScreenController());

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RemoteImage(
          url: ConfigService.to.general.app.image,
          height: 100,
          placeholder: Image.asset(Images.logo, height: 100),
        ),
        const SizedBox(height: 20),
        Text(
          ConfigService.to.appName,
          style: const TextStyle(fontSize: 25),
        ),
        if (!controller.passwordMode) ...[
          TextFormField(
            initialValue: Persistence.to.shortAddress,
            readOnly: true,
            textAlign: TextAlign.center,
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
                controller.passwordMode
                    ? Iconsax.arrow_circle_right
                    : LineIcons.lockOpen,
              ),
            ),
          ),
        ] else ...[
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
              validator: Utils.validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                hintText: 'master_password'.tr,
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
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: Obx(
              () => ElevatedButton.icon(
                label:
                    Text(controller.passwordMode ? 'proceed'.tr : 'unlock'.tr),
                icon: Icon(
                  controller.passwordMode
                      ? Iconsax.arrow_circle_right
                      : LineIcons.lockOpen,
                ),
                onPressed: controller.canProceed() ? controller.unlock : null,
              ),
            ),
          ),
        ]
      ],
    );

    return WillPopScope(
      onWillPop: () => Future.value(controller.passwordMode),
      child: Scaffold(
        appBar: controller.passwordMode ? AppBar() : null,
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
