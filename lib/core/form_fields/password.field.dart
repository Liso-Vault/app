import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:random_string_generator/random_string_generator.dart';

import '../../features/app/routes.dart';
import '../../features/items/item_screen.controller.dart';
import '../../features/menu/menu.button.dart';
import '../../features/menu/menu.item.dart';
import '../../features/pro/pro.controller.dart';
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
      (e as dynamic).children.first.child.field.identifier ==
      widget.field.identifier);

  HiveLisoField get formField => formWidget.children.first.child.field;

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
          obscureText ? Iconsax.eye : Iconsax.eye_slash,
        ),
      ),
      if (widget.isPasswordField && !widget.field.readOnly) ...[
        ContextMenuItem(
          title: 'Generate',
          leading: const Icon(Iconsax.password_check),
          onSelected: _generate,
        ),
      ],
      ContextMenuItem(
        title: 'Copy',
        leading: const Icon(Iconsax.copy),
        onSelected: () => Utils.copyToClipboard(widget.fieldController.text),
      ),
      if (!ProController.to.limits.passwordHealth) ...[
        ContextMenuItem(
          title: 'Password Health',
          leading: const Icon(Iconsax.health),
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
          leading: const Icon(LineIcons.times),
          onSelected: widget.fieldController.clear,
        ),
      ],
      if (!widget.field.reserved) ...[
        ContextMenuItem(
          title: 'Properties',
          leading: const Icon(Iconsax.setting),
          onSelected: () async {
            await ItemScreenController.to.showFieldProperties(formWidget);
            setState(() {});
          },
        ),
        ContextMenuItem(
          title: 'Remove',
          leading: const Icon(Iconsax.trash),
          onSelected: () => ItemScreenController.to.widgets.remove(formWidget),
        ),
      ]
    ];
  }

  // FUNCTIONS
  void _generate() async {
    final password_ = await Utils.adaptiveRouteOpen(
      name: Routes.passwordGenerator,
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
        helperText: ProController.to.limits.passwordHealth &&
                widget.isPasswordField &&
                widget.fieldController.text.isNotEmpty
            ? Utils.strengthName(strength).toUpperCase()
            : null,
        helperStyle: TextStyle(
          color: Utils.strengthColor(strength),
          fontWeight: FontWeight.bold,
        ),
        suffixIcon: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
      ),
    );
  }
}
