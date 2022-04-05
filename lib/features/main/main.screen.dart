import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/main/item.tile.dart';
import 'package:liso/resources/resources.dart';

import '../search/search.delegate.dart';
import 'drawer/drawer.widget.dart';
import 'main_screen.controller.dart';

class MainScreen extends GetView<MainScreenController> with ConsoleMixin {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = controller.obx(
      (_) => Obx(
        () => ListView.separated(
          shrinkWrap: true,
          itemCount: controller.data.length,
          itemBuilder: itemBuilder,
          separatorBuilder: (context, index) => const Divider(height: 0),
          padding: const EdgeInsets.only(bottom: 50),
        ),
      ),
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: LineIcons.seedling,
        message: 'no_items'.tr,
        child: TextButton.icon(
          label: Text('add_item'.tr),
          icon: const Icon(LineIcons.plus),
          onPressed: controller.add,
        ),
      ),
    );

    final floatingButton = FloatingActionButton(
      child: const Icon(LineIcons.plus),
      onPressed: controller.add,
    );

    final appBar = AppBar(
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Images.logo, height: 17),
          const SizedBox(width: 10),
          const Text(
            kAppName,
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LineIcons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: ItemsSearchDelegate(),
            );
          },
        ),
        IconButton(
          icon: const Icon(LineIcons.sort),
          onPressed: controller.showSortSheet,
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      drawer: const ZDrawer(),
      floatingActionButton: floatingButton,
      body: content,
    );
  }

  Widget itemBuilder(context, index) => ItemTile(controller.data[index]);
}
