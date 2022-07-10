import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/utils/globals.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import 'cipher_screen.controller.dart';

class CipherScreen extends StatelessWidget with ConsoleMixin {
  const CipherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CipherScreenController());

    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Encrypt your files and texts the same way your vault is encrypted using AES 256 Bit Encryption with PKCS7 Padding',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    Iconsax.shield_tick,
                    color: themeColor,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Iconsax.shield_tick, color: themeColor),
            trailing: const Icon(Iconsax.arrow_right_3),
            title: Text('encrypt_file'.tr),
            subtitle: const Text('Encrypt a file'),
            onTap: controller.encrypt,
          ),
          ListTile(
            onTap: controller.decrypt,
            leading: Icon(Iconsax.shield_cross, color: themeColor),
            trailing: const Icon(Iconsax.arrow_right_3),
            title: Text('decrypt_file'.tr),
            subtitle: const Text(
              'Decrypt a <file>$kEncryptedExtensionExtra file',
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Iconsax.shield_tick, color: themeColor),
            trailing: const Icon(Iconsax.arrow_right_3),
            title: Text('encrypt_text'.tr),
            subtitle: const Text('Encrypt texts'),
            onTap: controller.encryptText,
          ),
          ListTile(
            onTap: controller.decryptText,
            leading: Icon(Iconsax.shield_cross, color: themeColor),
            trailing: const Icon(Iconsax.arrow_right_3),
            title: Text('decrypt_text'.tr),
            subtitle: const Text('Decrypt texts'),
          ),
        ],
      ),
    );

    final appBar = AppBar(
      title: const Text('Cipher Tool'),
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
