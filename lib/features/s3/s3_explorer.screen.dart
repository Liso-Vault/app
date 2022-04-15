import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/main/main_screen.controller.dart';

import '../general/busy_indicator.widget.dart';
import '../general/centered_placeholder.widget.dart';

import 's3_content.tile.dart';
import 's3_exporer_screen.controller.dart';

class S3ExplorerScreen extends GetWidget<S3ExplorerScreenController>
    with ConsoleMixin {
  const S3ExplorerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(context, index) => S3ContentTile(
          content: controller.data[index],
          controller: controller,
        );

    final listView = Obx(
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) => const Divider(height: 0),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );

    final content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: LineIcons.cube,
        message: 'no_items'.tr,
      ),
    );

    final appBar = AppBar(
      title: Text('file_explorer'.tr),
      centerTitle: false,
      // X icon for desktop instead of back for mobile
      leading: MainScreenController.to.expandableDrawer
          ? null
          : IconButton(
              onPressed: Get.back,
              icon: const Icon(LineIcons.times),
            ),
      actions: [
        Obx(
          () => IconButton(
            onPressed:
                controller.canUp && !controller.busy() ? controller.up : null,
            icon: const Icon(LineIcons.alternateLevelUp),
          ),
        ),
        Obx(
          () => IconButton(
            onPressed: !controller.busy() ? controller.reload : null,
            icon: const Icon(LineIcons.syncIcon),
          ),
        ),
        IconButton(
          onPressed: !controller.busy() ? controller.test : null,
          icon: const Icon(LineIcons.bug),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Text(controller.currentPath.value)),
          ),
          const Divider(),
          Expanded(child: content),
        ],
      ),
    );
  }
}
