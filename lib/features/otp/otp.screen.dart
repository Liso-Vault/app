import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../core/utils/globals.dart';
import 'otp_screen.controller.dart';

class OTPScreen extends StatelessWidget with ConsoleMixin {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OTPScreenController());

    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Iconsax.convert_3d_cube_outline, size: 150, color: themeColor),
            const SizedBox(height: 20),
            Text(
              'otp_generator'.tr,
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 300,
              child: TextField(
                controller: controller.codeController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  label: Text('key'.tr, textAlign: TextAlign.center),
                  hintText: 'JBSWY3DPEHPK3PXP',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Text(
                "${'code'.tr}: ${controller.code.value}",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.generate,
              child: Text('generate'.tr),
            ),
          ],
        ),
      ),
    );

    final appBar = AppBar(
      title: Text('otp_generator'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: Text('need_help'.tr),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
