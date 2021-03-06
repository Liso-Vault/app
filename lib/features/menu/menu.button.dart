import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/menu/context.menu.dart';

import '../../core/utils/utils.dart';
import 'menu.item.dart';

class ContextMenuButton extends StatelessWidget with ConsoleMixin {
  final Widget child;
  final ContextMenuItem? initialItem;
  final bool useMouseRegion;
  final List<ContextMenuItem> contextItems;
  final EdgeInsets padding;
  final bool enabled;
  final bool sheetForSmallScreen;

  const ContextMenuButton(
    this.contextItems, {
    Key? key,
    required this.child,
    this.initialItem,
    this.useMouseRegion = false,
    this.padding = const EdgeInsets.all(8.0),
    this.enabled = true,
    this.sheetForSmallScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wrappedChild = Padding(
      padding: padding,
      child: child,
    );

    // if mobile / small screen
    if (Utils.isDrawerExpandable && sheetForSmallScreen) {
      return InkWell(
        onTap: enabled
            ? () => ContextMenuSheet(
                  contextItems,
                  initialItem: initialItem,
                ).show()
            : null,
        child: AbsorbPointer(child: wrappedChild),
      );
    }

    // if desktop / large screen
    final popupItems = contextItems.map(
      (e) {
        var leading = e.leading;

        if (e.leading is Icon) {
          final icon = e.leading as Icon;
          if (icon.color == null) {
            leading = Icon(icon.icon, color: themeColor, size: icon.size);
          }
        }

        return PopupMenuItem<ContextMenuItem>(
          value: e,
          child: Row(
            children: [
              if (leading != null) ...[leading],
              const SizedBox(width: 15),
              Text(
                e.title,
                style: TextStyle(color: e.isActive ? themeColor : null),
              ),
              if (e.trailing != null) ...[
                const Spacer(),
                e.trailing!,
              ]
            ],
          ),
        );
      },
    ).toList();

    if (!useMouseRegion || Utils.isDrawerExpandable) {
      return PopupMenuButton(
        onSelected: (ContextMenuItem menu) => menu.onSelected?.call(),
        itemBuilder: (context) => popupItems,
        initialValue: initialItem,
        enabled: enabled,
        child: AbsorbPointer(child: wrappedChild),
      );
    }

    // using MouseRegion
    Offset position = const Offset(0, 0);

    void _showMenu() async {
      final selectedItem = await showMenu(
        context: Get.context!,
        items: popupItems,
        initialValue: initialItem,
        position: RelativeRect.fromLTRB(
          position.dx,
          position.dy - 300,
          position.dx,
          position.dy,
        ),
      );

      selectedItem?.onSelected?.call();
    }

    return MouseRegion(
      onHover: (event) => position = event.position,
      child: InkWell(
        onTap: enabled ? _showMenu : null,
        child: AbsorbPointer(child: wrappedChild),
      ),
    );
  }
}
