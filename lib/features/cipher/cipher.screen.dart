import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/utils/globals.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import 'cipher_screen.controller.dart';

class CipherScreen extends GetView<CipherScreenController> with ConsoleMixin {
  const CipherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: encrypt & decrypt texts
    // TODO: sign & verify texts

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Iconsax.lock, color: themeColor),
            trailing: const Icon(Iconsax.arrow_right_3),
            title: Text('encrypt_file'.tr),
            subtitle: const Text('Choose a file to encrypt'),
            onTap: controller.encrypt,
          ),
          ListTile(
            onTap: controller.decrypt,
            leading: Icon(Iconsax.lock_slash, color: themeColor),
            trailing: const Icon(Iconsax.arrow_right_3),
            title: Text('decrypt_file'.tr),
            subtitle: const Text(
              'Decrypt a <file>$kEncryptedExtensionExtra file',
            ),
          ),
        ],
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
