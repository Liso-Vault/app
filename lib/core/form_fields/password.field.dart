import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:random_string_generator/random_string_generator.dart';

import '../../features/app/routes.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';
import '../utils/globals.dart';
import '../utils/utils.dart';

// ignore: must_be_immutable
class PasswordFormField extends GetWidget<PasswordFormFieldController>
    with ConsoleMixin {
  final HiveLisoField field;
  PasswordFormField(this.field, {Key? key}) : super(key: key);
  TextEditingController? _fieldController;
  String get value => _fieldController!.text;

  bool get isPasswordField => field.identifier == 'password';

  void _generate() async {
    final password_ = await Utils.adaptiveRouteOpen(
      name: Routes.passwordGenerator,
      parameters: {'return': 'true'},
    );

    if (password_ == null) return;
    controller.obscureText.value = false;
    _fieldController!.text = password_;
    controller.password.value = password_;
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
      if (isPasswordField) ...[
        ContextMenuItem(
          title: 'Generate',
          leading: const Icon(Iconsax.password_check),
          onSelected: _generate,
        ),
      ],
      ContextMenuItem(
        title: 'Copy',
        leading: const Icon(Iconsax.copy),
        onSelected: () => Utils.copyToClipboard(_fieldController!.text),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data.value);
    controller.password.value = field.data.value!;

    return Obx(
      () => TextFormField(
        controller: _fieldController,
        keyboardType: TextInputType.visiblePassword,
        obscureText: controller.obscureText.value,
        readOnly: field.readOnly,
        onChanged: (value) => controller.password.value = value,
        decoration: InputDecoration(
          labelText: field.data.label,
          hintText: field.data.hint,
          helperText:
              isPasswordField ? controller.strengthName.toUpperCase() : null,
          helperStyle: TextStyle(color: controller.strengthColor),
          suffixIcon: ContextMenuButton(
            menuItems,
            child: const Icon(LineIcons.verticalEllipsis),
          ),
        ),
      ),
    );
  }
}

class PasswordFormFieldController extends GetxController with ConsoleMixin {
  // PROPERTIES
  final password = ''.obs;
  final obscureText = true.obs;

  // GETTERS
  String get strengthName {
    String name = 'Very Weak'; // VERY WEAK

    if (strength == PasswordStrength.WEAK) {
      name = 'Weak';
    } else if (strength == PasswordStrength.GOOD) {
      name = 'Good';
    } else if (strength == PasswordStrength.STRONG) {
      name = 'Strong';
    }

    return name;
  }

  Color get strengthColor {
    Color color = Colors.red; // VERY WEAK

    if (strength == PasswordStrength.WEAK) {
      color = Colors.orange;
    } else if (strength == PasswordStrength.GOOD) {
      color = Colors.lime;
    } else if (strength == PasswordStrength.STRONG) {
      color = themeColor;
    }

    return color;
  }

  double get strengthValue =>
      (strength.index.toDouble() + 0.5) / PasswordStrength.STRONG.index;

  PasswordStrength get strength =>
      PasswordStrengthChecker.checkStrength(password.value);
}
