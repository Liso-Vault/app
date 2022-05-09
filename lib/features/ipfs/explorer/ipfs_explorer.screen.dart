import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipfs_rpc/ipfs_rpc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/menu/menu.item.dart';
import 'package:path/path.dart';

import '../../../core/utils/utils.dart';
import '../../general/appbar_leading.widget.dart';
import '../../general/busy_indicator.widget.dart';
import '../../general/centered_placeholder.widget.dart';
import '../../menu/menu.button.dart';
import 'ipfs_exporer_screen.controller.dart';

class IPFSExplorerScreen extends GetWidget<IPFSExplorerScreenController>
    with ConsoleMixin {
  const IPFSExplorerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(context, index) => FileTile(
          entry: controller.data[index],
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
      title: Text('time_machine_explorer'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        Obx(
          () => IconButton(
            onPressed: controller.canUp ? controller.up : null,
            icon: const Icon(LineIcons.alternateLevelUp),
          ),
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

class FileTile extends StatelessWidget with ConsoleMixin {
  final FilesLsEntry entry;
  final IPFSExplorerScreenController controller;

  const FileTile({
    Key? key,
    required this.entry,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      ContextMenuItem(
        title: 'Restore',
        leading: const Icon(LineIcons.trashRestore),
        onSelected: () => controller.restore(entry),
      ),
      if (!controller.currentPath.value.contains('/Backups')) ...[
        ContextMenuItem(
          title: 'Backup',
          leading: const Icon(LineIcons.fileDownload),
          onSelected: () => controller.backup(entry),
        ),
      ]
    ];

    return ListTile(
      title: Text(entry.name),
      subtitle: Text(filesize(entry.size)),
      iconColor: entry.type == FilesLsEntryType.file ? kAppColor : null,
      leading: Icon(
        entry.type == FilesLsEntryType.file
            ? LineIcons.fileAlt
            : LineIcons.folderOpen,
      ),
      trailing: entry.type == FilesLsEntryType.file
          ? ContextMenuButton(
              menuItems,
              child: const Icon(LineIcons.verticalEllipsis),
            )
          : null,
      onTap: () {
        if (entry.type == FilesLsEntryType.directory) {
          controller.load(path: join(controller.currentPath.value, entry.name));
        } else {
          _askToImport(entry);
        }
      },
    );
  }

  void _askToImport(FilesLsEntry entry) {
    final content = RichText(
      text: TextSpan(
        text: 'Are you sure you want to restore vault with hash: ',
        style: Get.theme.dialogTheme.contentTextStyle,
        children: <TextSpan>[
          TextSpan(
            text: entry.hash,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kAppColorDarker,
            ),
          ),
          const TextSpan(
              text:
                  '?\nCaution: This will overwrite your current local vault.'),
        ],
      ),
    );

    Get.dialog(AlertDialog(
      title: const Text('Restore From IPFS'),
      content: Utils.isDrawerExpandable
          ? content
          : SizedBox(
              width: 600,
              child: content,
            ),
      actions: [
        TextButton(
          child: Text('cancel'.tr),
          onPressed: Get.back,
        ),
        TextButton(
          child: Text('proceed'.tr),
          onPressed: () => controller.restore(entry),
        ),
      ],
    ));
  }
}
