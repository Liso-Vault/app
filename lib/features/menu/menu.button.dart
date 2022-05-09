import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:console_mixin/console_mixin.dart';
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

  const ContextMenuButton(
    this.contextItems, {
    Key? key,
    required this.child,
    this.initialItem,
    this.useMouseRegion = false,
    this.padding = const EdgeInsets.all(8.0),
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wrappedChild = Padding(
      padding: padding,
      child: child,
    );

    // if mobile / small screen
    if (Utils.isDrawerExpandable) {
      return InkWell(
        child: AbsorbPointer(child: wrappedChild),
        onTap: enabled
            ? () => ContextMenuSheet(
                  contextItems,
                  initialItem: initialItem,
                ).show()
            : null,
      );
    }

    // if desktop / large screen
    final popupItems = contextItems
        .map(
          (e) => PopupMenuItem<ContextMenuItem>(
            value: e,
            child: Row(
              children: [
                e.leading!,
                const SizedBox(width: 15),
                Text(e.title),
                if (e.trailing != null) ...[
                  const Spacer(),
                  e.trailing!,
                ]
              ],
            ),
          ),
        )
        .toList();

    if (!useMouseRegion) {
      return PopupMenuButton(
        onSelected: (ContextMenuItem menu) => menu.onSelected?.call(),
        itemBuilder: (context) => popupItems,
        child: AbsorbPointer(child: wrappedChild),
        initialValue: initialItem,
        enabled: enabled,
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
        child: AbsorbPointer(child: wrappedChild),
        onTap: enabled ? _showMenu : null,
      ),
    );
  }
}
