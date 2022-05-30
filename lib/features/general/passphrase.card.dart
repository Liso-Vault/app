import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SeedFormFieldController extends GetxController {
  final obscureText = true.obs;
}

class PassphraseCard extends GetWidget<SeedFormFieldController>
    with ConsoleMixin {
  final PassphraseMode mode;
  final String initialValue;
  final bool required;
  final TextEditingController seedController;
  final Function(String)? onFieldSubmitted;

  const PassphraseCard({
    Key? key,
    this.mode = PassphraseMode.none,
    this.initialValue = '',
    this.required = true,
    required this.seedController,
    this.onFieldSubmitted,
  }) : super(key: key);

  String? get value =>
      bip39.validateMnemonic(seedController.text) ? seedController.text : null;

  @override
  Widget build(BuildContext context) {
    _init();

    return Obx(
      () => TextFormField(
        controller: seedController,
        minLines: 1,
        // maxLines: 5,
        obscureText: controller.obscureText.value,
        textInputAction: TextInputAction.next,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (text) => _validateSeed(text!),
        onFieldSubmitted: onFieldSubmitted,
        inputFormatters: [
          // don't allow new lines
          FilteringTextInputFormatter.deny(RegExp(r'\n')),
        ],
        decoration: InputDecoration(
          labelText: 'Mnemonic Seed Phrase',
          suffixIcon: IconButton(
            padding: const EdgeInsets.only(right: 10),
            onPressed: controller.obscureText.toggle,
            icon: Icon(
              controller.obscureText.value ? Iconsax.eye : Iconsax.eye_slash,
            ),
          ),
        ),
      ),
    );
  }

  void _init() {
    seedController.text = initialValue;

    if (mode == PassphraseMode.create) {
      seedController.text = bip39.generateMnemonic(strength: 256);
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
