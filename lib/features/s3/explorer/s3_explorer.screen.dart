import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';

import '../../general/appbar_leading.widget.dart';
import '../../general/busy_indicator.widget.dart';
import '../../general/centered_placeholder.widget.dart';
import '../../menu/menu.button.dart';
import '../s3.service.dart';
import 's3_content.tile.dart';
import 's3_exporer_screen.controller.dart';

class S3ExplorerScreen extends StatelessWidget with ConsoleMixin {
  const S3ExplorerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(S3ExplorerScreenController());

    Widget itemBuilder(context, index) {
      final content = controller.data[index];

      return S3ContentTile(
        // key: ValueKey(content),
        content,
      );
    }

    final listView = Obx(
      () => RefreshIndicator(
        onRefresh: controller.pulledRefresh,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.data.length,
          itemBuilder: itemBuilder,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );

    var content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.document_cloud,
        message:
            controller.isTimeMachine ? 'No backed up vaults' : 'no_files'.tr,
      ),
    );

    // enable pull to refresh if mobile
    if (GetPlatform.isMobile) {
      content = RefreshIndicator(
        onRefresh: controller.pulledRefresh,
        child: content,
      );
    }

    final appBar = AppBar(
      title: Text(
        controller.isTimeMachine
            ? 'Time Machine'
            : (controller.isPicker ? 'File Picker' : 'files'.tr),
      ),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        Obx(
          () => IconButton(
            onPressed: !controller.isInRoot && !controller.busy()
                ? controller.up
                : null,
            icon: const Icon(LineIcons.alternateLevelUp),
          ),
        ),
        if (!controller.isTimeMachine) ...[
          Obx(
            () => IconButton(
              onPressed: !controller.busy() ? controller.newFolder : null,
              icon: const Icon(Iconsax.folder_add),
            ),
          ),
        ],
        Obx(
          () => IconButton(
            onPressed: !controller.busy() ? controller.reload : null,
            icon: const Icon(Iconsax.refresh),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );

    final floatingActionButton = Obx(
      () => Visibility(
        visible: !controller.isTimeMachine && !controller.busy(),
        replacement: const SizedBox.shrink(),
        child: ContextMenuButton(
          controller.menuItemsUploadType,
          child: FloatingActionButton(
            onPressed: controller.busy() ? null : controller.pickFile,
            child: const Icon(Iconsax.export_1),
          ),
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
            padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
            child: Obx(
              () => Text(
                controller.currentPath.value
                    .replaceAll(S3Service.to.rootPath, 'Root/'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
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
