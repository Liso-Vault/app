import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/utils/globals.dart';
import '../general/appbar_leading.widget.dart';
import 'otp_screen.controller.dart';

class OTPScreen extends GetView<OTPScreenController> with ConsoleMixin {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            Icon(Iconsax.convert_3d_cube, size: 150, color: themeColor),
            const SizedBox(height: 20),
            const Text(
              'OTP Generator',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 300,
              child: TextField(
                controller: controller.codeController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  label: Text('Key', textAlign: TextAlign.center),
                  hintText: 'JBSWY3DPEHPK3PXP',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Text(
                "Code: ${controller.code.value}",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.generate,
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );

    final appBar = AppBar(
      title: const Text('OTP Generator'),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
