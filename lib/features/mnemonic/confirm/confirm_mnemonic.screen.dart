import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';

import 'confirm_mnemonic_screen.controller.dart';

class ConfirmMnemonicScreen extends GetView<ConfirmMnemonicScreenController>
    with ConsoleMixin {
  const ConfirmMnemonicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          LineIcons.alternateShield,
          size: 100,
        ),
        const SizedBox(height: 20),
        const Text(
          'Confirm Mnemonic Phrase',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
        const Text(
          "Re-enter your backed up mnemonic seed phrase",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        controller.passphraseCard,
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: controller.continuePressed,
          label: const Text('Continue'),
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
