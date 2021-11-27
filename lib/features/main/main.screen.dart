import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/animations/animations.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';

import 'drawer/drawer.widget.dart';
import 'main_screen.controller.dart';

class MainScreen extends GetView<MainScreenController> {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(context, index) {
      final object = controller.data[index];

      return ListItemAnimation(
        child: ListTile(
          title: Text(
            object.address,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(object.description),
          onTap: () => Get.toNamed(Routes.seed, parameters: {
            'mode': 'update',
            'index': index.toString(),
          }),
        ),
      );
    }

    final content = controller.obx(
      (_) => ListView.separated(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) => const Divider(),
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
      appBar: AppBar(title: const Text(kName)),
      drawer: const ZDrawer(),
      floatingActionButton: floatingButton,
      body: content,
    );
  }
}
