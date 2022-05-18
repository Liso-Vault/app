import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/config/config.service.dart';

import '../../core/utils/globals.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import 'cipher_screen.controller.dart';

class CipherScreen extends GetWidget<CipherScreenController> with ConsoleMixin {
  const CipherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: encrypt & decrypt texts
    // TODO: sign & verify texts

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
              'Cipher Tool',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 15),
            Text(
              "Encrypt your files outside ${ConfigService.to.appName} with AES-256 Military-Grade Encryption.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 50),
            const Divider(),
            ListTile(
              leading: Icon(Iconsax.lock, color: themeColor),
              trailing: const Icon(Iconsax.arrow_right_3),
              title: Text('encrypt_file'.tr),
              subtitle: const Text('Choose a file to encrypt'),
              onTap: controller.encrypt,
            ),
            const Divider(),
            ListTile(
              onTap: controller.decrypt,
              leading: Icon(Iconsax.lock_slash, color: themeColor),
              trailing: const Icon(Iconsax.arrow_right_3),
              title: Text('decrypt_file'.tr),
              subtitle: const Text(
                'Decrypt a <file>$kEncryptedExtensionExtra file',
              ),
            ),
            // const Text('Select a file to encrypt'),
            // const SizedBox(height: 10),
            // SizedBox(
            //   width: 200,
            //   child: ElevatedButton.icon(
            //     icon: const Icon(Iconsax.eye_slash),
            //     label: Text('encrypt_file'.tr),
            //     onPressed: controller.encrypt,
            //   ),
            // ),
            // const Divider(height: 50),
            // const Text('Select a file to decrypt'),
            // const SizedBox(height: 10),
            // SizedBox(
            //   width: 200,
            //   child: ElevatedButton.icon(
            //     icon: const Icon(Iconsax.eye),
            //     label: Text('decrypt_file'.tr),
            //     onPressed: controller.decrypt,
            //   ),
            // ),
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
