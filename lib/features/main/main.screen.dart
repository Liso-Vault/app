import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/resources/resources.dart';

import '../../core/utils/utils.dart';
import 'drawer/drawer.widget.dart';
import 'main_screen.controller.dart';

class MainScreen extends GetView<MainScreenController> with ConsoleMixin {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(context, index) {
      final item = controller.data[index];

      return GestureDetector(
        // on mouse right click
        onSecondaryTap: () => controller.onLongPress(item),
        child: ListTile(
          leading: Utils.categoryIcon(
            LisoItemCategory.values.byName(item.category),
          ),
          title: Text(
            item.title,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            item.subTitle,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            item.metadata.updatedTimeAgo,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          onLongPress: () => controller.onLongPress(item),
          onTap: () => Get.toNamed(Routes.item, parameters: {
            'mode': 'update',
            'category': item.category,
            'hiveKey': item.key.toString(),
          }),
        ),
      );
    }

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
        message: 'empty',
        child: TextButton.icon(
          label: const Text('Add your first item'),
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
          icon: const Icon(LineIcons.sort),
          onPressed: () {
            //
          },
        )
      ],
    );

    return Scaffold(
      appBar: appBar,
      drawer: const ZDrawer(),
      floatingActionButton: floatingButton,
      body: content,
    );
  }
}
