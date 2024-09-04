import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'menu.item.dart';

class ContextMenuSheet extends StatelessWidget with ConsoleMixin {
  final List<ContextMenuItem> contextItems;
  final ContextMenuItem? initialItem;

  const ContextMenuSheet(
    this.contextItems, {
    super.key,
    this.initialItem,
  });

  Future<void> show() async {
    return await Get.bottomSheet(
      this,
      isScrollControlled: false,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(context, index) {
      final item = contextItems[index];

      return ListTile(
        // iconColor: themeColor,
        title: Text(item.title),
        leading: item.leading,
        trailing: item.trailing,
        selected: item == initialItem,
        onTap: () {
          Get.back();
          item.onSelected?.call();
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: contextItems.length,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
