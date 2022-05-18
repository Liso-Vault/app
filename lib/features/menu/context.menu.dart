import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/animations/animations.dart';
import 'package:console_mixin/console_mixin.dart';
import 'menu.item.dart';

class ContextMenuSheet extends StatelessWidget with ConsoleMixin {
  final List<ContextMenuItem> contextItems;
  final ContextMenuItem? initialItem;

  const ContextMenuSheet(
    this.contextItems, {
    Key? key,
    this.initialItem,
  }) : super(key: key);

  Future<void> show() async {
    return await Get.bottomSheet(
      this,
      isScrollControlled: false,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _itemBuilder(context, index) {
      final item = contextItems[index];

      final tile = ListTile(
        iconColor: themeColor,
        title: Text(item.title),
        leading: item.leading,
        trailing: item.trailing,
        selected: item == initialItem,
        onTap: () {
          Get.back();
          item.onSelected?.call();
        },
      );

      return ListItemAnimation(
        delay: 100.milliseconds,
        duration: 300.milliseconds,
        child: tile,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: contextItems.length,
      itemBuilder: _itemBuilder,
      padding: const EdgeInsets.all(15),
    );
  }
}
