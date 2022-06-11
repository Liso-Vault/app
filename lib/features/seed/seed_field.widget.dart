import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../menu/menu.item.dart';

class SeedFormFieldController extends GetxController {
  final obscureText = true.obs;
}

class SeedField extends GetWidget<SeedFormFieldController> with ConsoleMixin {
  final String initialValue;
  final bool required;
  final bool showGenerate;
  final bool readOnly;
  final TextEditingController fieldController;
  final Function(String)? onFieldSubmitted;

  const SeedField({
    Key? key,
    this.initialValue = '',
    this.required = true,
    this.showGenerate = true,
    this.readOnly = false,
    required this.fieldController,
    this.onFieldSubmitted,
  }) : super(key: key);

  String? get value => bip39.validateMnemonic(fieldController.text)
      ? fieldController.text
      : null;

  @override
  Widget build(BuildContext context) {
    fieldController.text = initialValue;

    return Obx(
      () => TextFormField(
        controller: fieldController,
        minLines: 1,
        obscureText: controller.obscureText.value,
        textInputAction: TextInputAction.next,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (text) => _validateSeed(text!),
        readOnly: readOnly,
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
      ),
    );
  }

  void _generate() async {
    final seed = await Utils.adaptiveRouteOpen(
      name: Routes.seedGenerator,
      parameters: {'return': 'true'},
    );

    if (seed == null) return;
    controller.obscureText.value = false;
    fieldController.text = seed;
  }

  String? _validateSeed(String seed) {
    if (required && seed.isEmpty) {
      return 'Required';
    } else if (seed.isNotEmpty && !bip39.validateMnemonic(seed)) {
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
      if (showGenerate) ...[
        ContextMenuItem(
          title: 'Generate',
          leading: const Icon(Iconsax.password_check),
          onSelected: _generate,
        ),
      ],
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
