import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';
import '../utils/utils.dart';

// ignore: must_be_immutable
class PasswordFormField extends GetWidget<PasswordFormFieldController> {
  final HiveLisoField field;
  PasswordFormField(this.field, {Key? key}) : super(key: key);
  TextEditingController? _fieldController;
  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data.value);

    return Column(
      children: [
        Obx(
          () => TextFormField(
            controller: _fieldController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: controller.obscureText.value,
            readOnly: field.readOnly,
            decoration: InputDecoration(
              labelText: field.data.label,
              hintText: field.data.hint,
              suffixIcon: ContextMenuButton(
                menuItems,
                child: const Icon(LineIcons.verticalEllipsis),
              ),
            ),
          ),
          // TODO: validator widget here
        ),
      ],
    );
  }

  void _generate() {
    controller.obscureText.value = false;
    // TODO: show generator dialog
  }

  List<ContextMenuItem> get menuItems {
    final excluded = field.data.extra?['excluded_actions'] ?? [];

    return [
      if (!excluded.contains('visibility')) ...[
        ContextMenuItem(
          title: controller.obscureText.value ? 'Show' : 'Hide',
          onSelected: controller.obscureText.toggle,
          leading: Icon(
            controller.obscureText.value ? Iconsax.eye : Iconsax.eye_slash,
          ),
        ),
      ],
      if (!excluded.contains('generate')) ...[
        ContextMenuItem(
          title: 'Generate',
          leading: const Icon(Iconsax.password_check),
          onSelected: _generate,
        ),
      ],
      if (!excluded.contains('copy')) ...[
        ContextMenuItem(
          title: 'Copy',
          leading: const Icon(Iconsax.copy),
          onSelected: () => Utils.copyToClipboard(_fieldController!.text),
        ),
      ]
    ];
  }
}

class PasswordFormFieldController extends GetxController {
  final obscureText = true.obs;
}
