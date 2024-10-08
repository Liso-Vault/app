import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:blur/blur.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../app/routes.dart';
import '../menu/menu.item.dart';

class SeedField extends StatelessWidget with ConsoleMixin {
  final bool required;
  final bool showGenerate;
  final bool readOnly;
  final TextEditingController? fieldController;
  final Function(String)? onFieldSubmitted;

  SeedField({
    super.key,
    this.required = true,
    this.showGenerate = true,
    this.readOnly = false,
    required this.fieldController,
    this.onFieldSubmitted,
  });

  String? get value => bip39.validateMnemonic(fieldController!.text)
      ? fieldController!.text
      : null;

  final blur = true.obs;

  void _generate() async {
    final seed = await Utils.adaptiveRouteOpen(
      name: AppRoutes.seedGenerator,
      parameters: {'return': 'true'},
    );

    if (seed == null) return;
    fieldController!.text = seed;
    blur.value = false;
  }

  String? _validateSeed(String seed) {
    if (required && seed.isEmpty) {
      return 'Required';
    } else if (seed.isNotEmpty && !bip39.validateMnemonic(seed.trim())) {
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
        leading: Icon(Iconsax.eye_slash_outline, size: popupIconSize),
      ),
      if (showGenerate && !readOnly) ...[
        ContextMenuItem(
          title: 'Generate',
          leading: Icon(Iconsax.password_check_outline, size: popupIconSize),
          onSelected: _generate,
        ),
      ],
      ContextMenuItem(
        title: 'QR Code',
        leading: Icon(Iconsax.barcode_outline, size: popupIconSize),
        onSelected: () {
          if (fieldController!.text.isEmpty) return;

          AppUtils.showQR(
            fieldController!.text,
            title: 'Your Seed QR Code',
            subTitle:
                "Make sure you're in a safe location and free from prying eyes",
          );
        },
      ),
      ContextMenuItem(
        title: 'Copy',
        leading: Icon(Iconsax.copy_outline, size: popupIconSize),
        onSelected: () => Utils.copyToClipboard(fieldController!.text),
      ),
      if (!readOnly) ...[
        ContextMenuItem(
          title: 'Clear',
          leading: Icon(LineAwesome.times_solid, size: popupIconSize),
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
          child: const Icon(LineAwesome.ellipsis_v_solid),
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
          icon: const Icon(Iconsax.eye_outline),
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
