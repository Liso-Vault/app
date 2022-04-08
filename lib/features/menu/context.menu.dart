import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/animations/animations.dart';
import '../../core/utils/console.dart';
import 'menu.item.dart';

class ContextMenu extends StatelessWidget with ConsoleMixin {
  final List<ContextMenuItem> items;
  final ContextMenuItem? initialItem;
  final Offset? position;

  const ContextMenu({
    Key? key,
    required this.items,
    this.initialItem,
    required this.position,
  }) : super(key: key);

  Future<void> show() async {
    if (GetPlatform.isMobile) {
      return await Get.bottomSheet(
        this,
        isScrollControlled: false,
        backgroundColor: Get.theme.scaffoldBackgroundColor,
      );
    }

    if (position == null) return console.error('null position');

    final rect = RelativeRect.fromLTRB(
      position!.dx,
      position!.dy,
      position!.dx,
      position!.dy,
    );

    showMenu(
      context: Get.context!,
      position: rect,
      items: items
          .map(
            (e) => PopupMenuItem<ContextMenuItem>(
              value: e,
              onTap: () => e.function?.call(),
              child: Row(
                children: [
                  e.leading!,
                  const SizedBox(width: 15),
                  Text(e.title),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _itemBuilder(context, index) {
      final item = items[index];

      final tile = ListTile(
        title: Text(item.title),
        leading: item.leading,
        selected: item == initialItem,
        onTap: () {
          Get.back();
          item.function?.call();
        },
      );

      return ListItemAnimation(
        child: tile,
        delay: 100.milliseconds,
        duration: 300.milliseconds,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: _itemBuilder,
      padding: const EdgeInsets.all(15),
    );
  }
}
