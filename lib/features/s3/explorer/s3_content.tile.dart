import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/s3/explorer/s3_exporer_screen.controller.dart';

import 'package:console_mixin/console_mixin.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/utils.dart';
import '../../menu/menu.button.dart';
import '../../menu/menu.item.dart';
import '../model/s3_content.model.dart';

class S3ContentTile extends StatelessWidget with ConsoleMixin {
  final S3Content content;
  final S3ExplorerScreenController controller;

  const S3ContentTile({
    Key? key,
    required this.content,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      if (content.isVaultFile) ...[
        ContextMenuItem(
          title: 'Restore',
          leading: const Icon(LineIcons.trashRestore),
          onSelected: () => controller.restore(content),
        ),
        if (!controller.currentPath.value.contains('Backups/')) ...[
          ContextMenuItem(
            title: 'Backup',
            leading: const Icon(LineIcons.fileDownload),
            onSelected: () => controller.backup(content),
          ),
        ]
      ] else ...[
        if (content.isFile) ...[
          ContextMenuItem(
            title: 'Download',
            leading: const Icon(LineIcons.download),
            onSelected: () => controller.download(content),
          ),
        ],
        ContextMenuItem(
          title: 'Delete',
          leading: const Icon(LineIcons.trash),
          onSelected: () => controller.confirmDelete(content),
        ),
      ],
    ];

    return ListTile(
      title: Text(content.name),
      subtitle: content.size > 0
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(filesize(content.size)),
                if (content.object != null) Text(content.updatedTimeAgo),
              ],
            )
          : null,
      iconColor: content.isFile ? kAppColor : null,
      leading: Icon(
        content.isFile ? LineIcons.fileAlt : LineIcons.folderOpen,
      ),
      trailing: ContextMenuButton(
        menuItems,
        child: const Icon(LineIcons.verticalEllipsis),
      ),
      onTap: () {
        if (content.isFile) {
          if (content.isVaultFile) {
            _askToImport(content);
          } else {
            // TODO: ask to download or preview
          }
        } else {
          controller.load(path: content.path);
        }
      },
    );
  }

  void _askToImport(S3Content s3content) {
    const content = Text(
      'Are you sure you want to restore from this vault? \nYour current vault will be overwritten.',
    );

    Get.dialog(AlertDialog(
      title: Text('restore'.tr),
      content: Utils.isDrawerExpandable
          ? content
          : const SizedBox(
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
          onPressed: () => controller.restore(s3content),
        ),
      ],
    ));
  }
}
