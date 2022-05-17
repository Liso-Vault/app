import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/passphrase.card.dart';

import '../../../core/utils/globals.dart';
import 'confirm_mnemonic_screen.controller.dart';

class ConfirmMnemonicScreen extends GetView<ConfirmMnemonicScreenController>
    with ConsoleMixin {
  const ConfirmMnemonicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Iconsax.key_square, size: 100, color: kAppColor),
        const SizedBox(height: 20),
        const Text(
          'Confirm Seed',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
        const Text(
          "Re-enter your seed phrase",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        PassphraseCard(
          controller: controller.seedController,
          onFieldSubmitted: (text) => controller.continuePressed,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: controller.continuePressed,
            label: Text('continue'.tr),
            icon: const Icon(Iconsax.arrow_circle_right),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: Styles.containerConstraints,
            child: SingleChildScrollView(child: content),
          ),
        ),
      ),
    );
  }
}
