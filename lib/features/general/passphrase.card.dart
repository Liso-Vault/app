import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/utils/utils.dart';
import '../menu/menu.item.dart';

class SeedFormFieldController extends GetxController {
  final obscureText = true.obs;
}

class PassphraseCard extends GetWidget<SeedFormFieldController>
    with ConsoleMixin {
  final String initialValue;
  final bool required;
  final TextEditingController fieldController;
  final Function(String)? onFieldSubmitted;

  const PassphraseCard({
    Key? key,
    this.initialValue = '',
    this.required = true,
    required this.fieldController,
    this.onFieldSubmitted,
  }) : super(key: key);

  String? get value => bip39.validateMnemonic(fieldController.text)
      ? fieldController.text
      : null;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: fieldController,
      minLines: 1,
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
        suffixIcon: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
      ),
    );
  }

  void _generate() {
    controller.obscureText.value = false;
    // TODO: show generator dialog
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

  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: controller.obscureText.value ? 'Show' : 'Hide',
        onSelected: controller.obscureText.toggle,
        leading: Icon(
          controller.obscureText.value ? Iconsax.eye : Iconsax.eye_slash,
        ),
      ),
      ContextMenuItem(
        title: 'Generate',
        leading: const Icon(Iconsax.password_check),
        onSelected: _generate,
      ),
      ContextMenuItem(
        title: 'Copy',
        leading: const Icon(Iconsax.copy),
        onSelected: () => Utils.copyToClipboard(fieldController.text),
      ),
    ];
  }
}

enum PassphraseMode {
  create,
  confirm,
  import,
  none,
}
