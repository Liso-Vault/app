import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/firebase/config/config.service.dart';

import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import 'cipher_screen.controller.dart';

class CipherScreen extends GetWidget<CipherScreenController> with ConsoleMixin {
  const CipherScreen({Key? key}) : super(key: key);

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
            const Icon(LineIcons.userSecret, size: 150),
            Text(
              "Protect your files using your private key with\n${ConfigService.to.appName}'s AES-256 Military-Grade Encryption.\nOnly you can decrypt them.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 50),
            const Text('Select a file to encrypt'),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(LineIcons.eyeSlash),
                label: Text('encrypt_file'.tr),
                onPressed: controller.encrypt,
              ),
            ),
            const Divider(height: 50),
            const Text('Select a file to decrypt'),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(LineIcons.eye),
                label: Text('decrypt_file'.tr),
                onPressed: controller.decrypt,
              ),
            ),
          ],
        ),
      ),
    );

    final appBar = AppBar(
      title: const Text('Cipher'),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
    );

    return Scaffold(
      appBar: appBar,
      body: controller.obx(
        (_) => content,
        onLoading: const BusyIndicator(),
      ),
    );
  }
}
