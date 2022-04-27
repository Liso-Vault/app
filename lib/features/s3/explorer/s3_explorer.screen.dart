import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';

import '../../general/appbar_leading.widget.dart';
import '../../general/busy_indicator.widget.dart';
import '../../general/centered_placeholder.widget.dart';
import '../s3.service.dart';
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
      () => RefreshIndicator(
        onRefresh: controller.pulledRefresh,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: controller.data.length,
          itemBuilder: itemBuilder,
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(height: 0),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );

    var content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: LineIcons.file,
        message: 'no_files'.tr,
      ),
    );

    // enable pull to refresh if mobile
    if (GetPlatform.isMobile) {
      content = RefreshIndicator(
        child: content,
        onRefresh: controller.pulledRefresh,
      );
    }

    final appBar = AppBar(
      title: Text(
        controller.isTimeMachine ? 'Time Machine' : 'file_explorer'.tr,
      ),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        Obx(
          () => IconButton(
            onPressed:
                controller.canUp && !controller.busy() ? controller.up : null,
            icon: const Icon(LineIcons.alternateLevelUp),
          ),
        ),
        if (!controller.isTimeMachine) ...[
          Obx(
            () => IconButton(
              onPressed: !controller.busy() ? controller.newFolder : null,
              icon: const Icon(LineIcons.folderPlus),
            ),
          ),
        ],
        Obx(
          () => IconButton(
            onPressed: !controller.busy() ? controller.reload : null,
            icon: const Icon(LineIcons.syncIcon),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );

    final floatingActionButton = Obx(
      () => Visibility(
        visible: !controller.isTimeMachine && !controller.busy(),
        replacement: const SizedBox.shrink(),
        child: FloatingActionButton(
          child: const Icon(LineIcons.upload),
          onPressed: controller.busy() ? null : controller.pickFile,
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
            child: Obx(
              () => Text(
                controller.currentPath.value
                    .replaceAll(S3Service.to.rootPath, 'Root/'),
              ),
            ),
          ),
          const Divider(),
          Expanded(child: content),
        ],
      ),
    );
  }
}
