import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/animations/animations.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/resources/resources.dart';

import 'drawer/drawer.widget.dart';
import 'main_screen.controller.dart';

class MainScreen extends GetView<MainScreenController> with ConsoleMixin {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(context, index) {
      final object = controller.data[index];

      final title = Text(
        object.address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

      final subTitle = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            object.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Image.asset(
                Utils.originImageParser(object.origin),
                width: 15,
              ),
              const SizedBox(width: 5),
              Text(
                object.origin,
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 10),
              const Icon(LineIcons.connectDevelop, size: 15),
              const SizedBox(width: 5),
              Text(
                object.ledger,
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 10),
              const Icon(LineIcons.clock, size: 15),
              const SizedBox(width: 5),
              Text(
                object.metadata.updatedTimeAgo,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          )
        ],
      );

      return ListItemAnimation(
        child: GestureDetector(
          child: ListTile(
            title: title,
            subtitle: subTitle,
            onTap: () => Get.toNamed(Routes.seed, parameters: {
              'mode': 'update',
              'index': index.toString(),
            }),
            onLongPress: () => controller.onLongPress(object),
          ),
          // on mouse right click
          onSecondaryTap: () => controller.onLongPress(object),
        ),
      );
    }

    final content = controller.obx(
      (_) => ListView.separated(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) => const Divider(),
        padding: const EdgeInsets.only(bottom: 50),
      ),
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: LineIcons.seedling,
        message: 'empty',
        child: TextButton.icon(
          label: const Text('Add your first seed'),
          icon: const Icon(LineIcons.plus),
          onPressed: controller.add,
        ),
      ),
    );

    final floatingButton = FloatingActionButton(
      child: const Icon(LineIcons.plus),
      onPressed: controller.add,
    );

    return Scaffold(
      appBar: AppBar(
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
      ),
      drawer: const ZDrawer(),
      floatingActionButton: floatingButton,
      body: content,
    );
  }
}
