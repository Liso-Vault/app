import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
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
        const Icon(LineIcons.doubleCheck, size: 100, color: kAppColor),
        const SizedBox(height: 20),
        const Text(
          'Confirm Seed Phrase',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
        const Text(
          "Re-enter your backed up master mnemonic seed phrase",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        PassphraseCard(controller: controller.seedController),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: controller.continuePressed,
          label: Text('continue'.tr),
          icon: const Icon(LineIcons.arrowRight),
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
