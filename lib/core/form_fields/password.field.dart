import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:random_string_generator/random_string_generator.dart';

import '../../features/app/routes.dart';
import '../../features/items/item_screen.controller.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';
import '../utils/globals.dart';
import '../utils/utils.dart';

class PasswordFormField extends StatefulWidget {
  final HiveLisoField field;
  final TextEditingController fieldController;
  final bool enabled;

  const PasswordFormField(
    this.field, {
    Key? key,
    required this.fieldController,
    this.enabled = true,
  }) : super(key: key);

  String get value => fieldController.text;

  bool get isPasswordField => !kNonPasswordFieldIds.contains(field.identifier);

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  // VARIABLES
  bool obscureText = true;

  // GETTERS
  dynamic get formWidget => ItemScreenController.to.widgets.firstWhere((e) =>
      (e as dynamic).children.first.child.child.field.identifier ==
      widget.field.identifier);

  // HiveLisoField get formField => formWidget.children.first.child.field;

  double get strengthValue =>
      (strength.index.toDouble() + 0.5) / PasswordStrength.STRONG.index;

  PasswordStrength get strength =>
      PasswordStrengthChecker.checkStrength(widget.fieldController.text);

  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: obscureText ? 'Show' : 'Hide',
        onSelected: () => setState(() {
          obscureText = !obscureText;
        }),
        leading: Icon(
          obscureText ? Iconsax.eye_outline : Iconsax.eye_slash_outline,
          size: popupIconSize,
        ),
      ),
      if (widget.isPasswordField && !widget.field.readOnly) ...[
        ContextMenuItem(
          title: 'Generate',
          leading: Icon(Iconsax.password_check_outline, size: popupIconSize),
          onSelected: _generate,
        ),
      ],
      ContextMenuItem(
        title: 'Copy',
        leading: Icon(Iconsax.copy_outline, size: popupIconSize),
        onSelected: () => Utils.copyToClipboard(widget.fieldController.text),
      ),
      if (!limits.passwordHealth) ...[
        ContextMenuItem(
          title: 'Password Health',
          leading: Icon(Iconsax.health_outline, size: popupIconSize),
          onSelected: () => Utils.adaptiveRouteOpen(
            name: Routes.upgrade,
            parameters: {
              'title': 'Password Health',
              'body':
                  'Monitor the health of your passwords. Upgrade to Pro to take advantage of this powerful feature.',
            },
          ),
        ),
      ],
      if (!widget.field.readOnly) ...[
        ContextMenuItem(
          title: 'Clear',
          leading: Icon(LineAwesome.times_solid, size: popupIconSize),
          onSelected: widget.fieldController.clear,
        ),
      ],
      if (!widget.field.reserved) ...[
        ContextMenuItem(
          title: 'Properties',
          leading: Icon(Iconsax.setting_outline, size: popupIconSize),
          onSelected: () async {
            await ItemScreenController.to.showFieldProperties(formWidget);
            setState(() {});
          },
        ),
        ContextMenuItem(
          title: 'Remove',
          leading: Icon(Iconsax.trash_outline, size: popupIconSize),
          onSelected: () => ItemScreenController.to.widgets.remove(formWidget),
        ),
      ]
    ];
  }

  // FUNCTIONS
  void _generate() async {
    final password_ = await Utils.adaptiveRouteOpen(
      name: AppRoutes.passwordGenerator,
      parameters: {'return': 'true'},
    );

    if (password_ == null) return;
    widget.fieldController.text = password_;

    setState(() {
      obscureText = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: widget.fieldController,
      obscureText: obscureText,
      keyboardType: TextInputType.visiblePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: widget.field.readOnly,
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
        labelText: widget.field.data.label,
        hintText: widget.field.data.hint,
        helperText: limits.passwordHealth &&
                widget.isPasswordField &&
                widget.fieldController.text.isNotEmpty
            ? AppUtils.strengthName(strength).toUpperCase()
            : null,
        helperStyle: TextStyle(
          color: AppUtils.strengthColor(strength),
          fontWeight: FontWeight.bold,
        ),
        suffixIcon: ContextMenuButton(
          menuItems,
          child: const Icon(LineAwesome.ellipsis_v_solid),
        ),
      ),
    );
  }
}
