import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liso/core/utils/console.dart';

class PassphraseCard extends StatelessWidget with ConsoleMixin {
  final PassphraseMode mode;
  final String initialValue;
  final bool required;
  final TextEditingController controller;
  final Function(String)? onFieldSubmitted;

  const PassphraseCard({
    Key? key,
    this.mode = PassphraseMode.none,
    this.initialValue = '',
    this.required = true,
    required this.controller,
    this.onFieldSubmitted,
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
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: [
        // don't allow new lines
        FilteringTextInputFormatter.deny(RegExp(r'\n')),
      ],
      decoration: const InputDecoration(
        labelText: 'Mnemonic Seed Phrase',
      ),
    );
  }

  void _init() {
    controller.text = initialValue;

    if (mode == PassphraseMode.create) {
      controller.text = bip39.generateMnemonic(strength: 256);
    } else if (mode == PassphraseMode.confirm) {
      //
    } else if (mode == PassphraseMode.import) {
      //
    } else if (mode == PassphraseMode.none) {
      //
    }
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
