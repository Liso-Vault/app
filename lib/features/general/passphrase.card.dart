import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:liso/core/utils/console.dart';

class PassphraseCard extends StatelessWidget with ConsoleMixin {
  final PassphraseMode mode;
  final String initialValue;
  final bool required;
  final TextEditingController controller;

  const PassphraseCard({
    Key? key,
    this.mode = PassphraseMode.none,
    this.initialValue = '',
    this.required = true,
    required this.controller,
  }) : super(key: key);

  String? obtainMnemonicPhrase() =>
      bip39.validateMnemonic(controller.text) ? controller.text : null;

  @override
  Widget build(BuildContext context) {
    _init();

    return TextFormField(
      controller: controller,
      minLines: 1,
      maxLines: 5,
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (text) => _validateSeed(text!),
      decoration: const InputDecoration(
        labelText: 'Mnemonic Seed Phrase',
      ),
    );
  }

  void _init() {
    controller.text = initialValue;

    if (mode == PassphraseMode.create) {
      _generateSeed(strength: 256);
    } else if (mode == PassphraseMode.confirm) {
      //
    } else if (mode == PassphraseMode.import) {
      //
    } else if (mode == PassphraseMode.none) {
      //
    }
  }

  void _generateSeed({required int strength}) {
    controller.text = bip39.generateMnemonic(strength: strength);
  }

  String? _validateSeed(String mnemonic) {
    if (required && mnemonic.isEmpty) {
      return 'Required';
    } else if (mnemonic.isNotEmpty && !bip39.validateMnemonic(mnemonic)) {
      return 'Invalid seed phrase';
    } else {
      return null;
    }
  }
}

enum PassphraseMode {
  create,
  confirm,
  import,
  none,
}
