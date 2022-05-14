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
    Widget _leadingIcon() {
      if (!content.isFile) return const Icon(Icons.folder);
      var _iconData = Icons.insert_drive_file;
      if (content.fileType == null) return Icon(_iconData);

      switch (content.fileType!) {
        case 'image':
          _iconData = Icons.photo;
          break;
        case 'video':
          _iconData = Icons.play_arrow_rounded;
          break;
        case 'archive':
          _iconData = Icons.archive;
          break;
        case 'audio':
          _iconData = Icons.audio_file;
          break;
        case 'code':
          _iconData = Icons.code;
          break;
        case 'book':
          _iconData = Icons.menu_book_rounded;
          break;
        case 'exec':
          _iconData = Icons.computer;
          break;
        case 'web':
          _iconData = LineIcons.chrome;
          break;
        case 'sheet':
          _iconData = LineIcons.excelFile;
          break;
        case 'text':
          _iconData = Icons.drive_file_rename_outline_rounded;
          break;
        case 'font':
          _iconData = Icons.font_download;
          break;
      }

      return Icon(_iconData);
    }

    void _askToDownload() {
      final _content = Text('Save "${content.maskedName}" to local disk?');

      Get.dialog(AlertDialog(
        title: const Text('Download'),
        content: Utils.isDrawerExpandable
            ? _content
            : SizedBox(width: 600, child: _content),
        actions: [
          TextButton(
            child: Text('cancel'.tr),
            onPressed: Get.back,
          ),
          TextButton(
            child: const Text('Download'),
            onPressed: () {
              Get.back();
              controller.download(content);
            },
          ),
        ],
      ));
    }

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
            onSelected: _askToDownload,
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
      title: Text(content.maskedName),
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
      leading: _leadingIcon(),
      trailing: ContextMenuButton(
        menuItems,
        child: const Icon(LineIcons.verticalEllipsis),
      ),
      onTap: () {
        if (content.isFile) {
          if (content.isVaultFile) {
            _askToImport(content);
          } else {
            _askToDownload();
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
