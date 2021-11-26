import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/passphrase_card/passphrase_card.controller.dart';

class PassphraseCard extends GetWidget<PassphraseCardController>
    with ConsoleMixin {
  final PassphraseMode mode;
  final String phrase;

  const PassphraseCard({
    Key? key,
    this.mode = PassphraseMode.none,
    this.phrase = '',
  }) : super(key: key);

  String? obtainMnemonicPhrase() {
    final seed = controller.mnemonicController.text;
    return bip39.validateMnemonic(seed) ? seed : null;
  }

  @override
  Widget build(BuildContext context) {
    controller.init(mode: mode, phrase: phrase);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.mnemonicController,
            minLines: 2,
            maxLines: 5,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (text) => controller.validateSeed(text!),
            decoration: Styles.inputDecoration.copyWith(
              labelText: 'Mnemonic Seed Phrase',
            ),
          ),
        ),
        // const SizedBox(width: 10),
        // Obx(
        //   () => IconButton(
        //     onPressed: controller.obscured.toggle,
        //     icon: Icon(
        //       controller.obscured() ? LineIcons.eyeSlash : LineIcons.eye,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
