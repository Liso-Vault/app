import 'package:bip39/bip39.dart' as bip39;
import 'package:blur/blur.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../menu/menu.item.dart';

class SeedField extends StatelessWidget with ConsoleMixin {
  final bool required;
  final bool showGenerate;
  final bool readOnly;
  final TextEditingController? fieldController;
  final Function(String)? onFieldSubmitted;

  SeedField({
    Key? key,
    this.required = true,
    this.showGenerate = true,
    this.readOnly = false,
    required this.fieldController,
    this.onFieldSubmitted,
  }) : super(key: key);

  String? get value => bip39.validateMnemonic(fieldController!.text)
      ? fieldController!.text
      : null;

  final blur = true.obs;

  void _generate() async {
    final seed = await Utils.adaptiveRouteOpen(
      name: Routes.seedGenerator,
      parameters: {'return': 'true'},
    );

    if (seed == null) return;
    fieldController!.text = seed;
    blur.value = false;
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
        title: 'Hide',
        onSelected: () => blur.value = true,
        leading: const Icon(Iconsax.eye_slash),
      ),
      if (showGenerate && !readOnly) ...[
        ContextMenuItem(
          title: 'Generate',
          leading: const Icon(Iconsax.password_check),
          onSelected: _generate,
        ),
      ],
      ContextMenuItem(
        title: 'QR Code',
        leading: const Icon(Iconsax.barcode),
        onSelected: () => UIUtils.showQR(
          fieldController!.text,
          title: 'Your Seed QR Code',
          subTitle:
              "Make sure you're in a safe location and free from prying eyes",
        ),
      ),
      ContextMenuItem(
        title: 'Copy',
        leading: const Icon(Iconsax.copy),
        onSelected: () => Utils.copyToClipboard(fieldController!.text),
      ),
      if (!readOnly) ...[
        ContextMenuItem(
          title: 'Clear',
          leading: const Icon(LineIcons.times),
          onSelected: fieldController!.clear,
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    blur.value = fieldController!.text.isNotEmpty;

    final field = TextFormField(
      controller: fieldController,
      minLines: 1,
      maxLines: 3,
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
    );

    final hiddenField = Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Blur(
              blur: 5.0,
              blurColor: Colors.grey.shade900,
              child: field,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Iconsax.eye),
          onPressed: () => blur.value = false,
        ),
      ],
    );

    return Obx(
      () => IndexedStack(
        index: blur.value ? 0 : 1,
        children: [hiddenField, field],
      ),
    );
  }
}
