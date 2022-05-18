import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/s3/explorer/s3_exporer_screen.controller.dart';

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
      if (!content.isFile) return const Icon(Iconsax.folder_open5);
      var iconData = Iconsax.document_1;
      if (content.fileType == null) return Icon(iconData);

      switch (content.fileType!) {
        case 'image':
          iconData = Iconsax.gallery;
          break;
        case 'video':
          iconData = Iconsax.play;
          break;
        case 'archive':
          iconData = Iconsax.archive;
          break;
        case 'audio':
          iconData = Iconsax.music;
          break;
        case 'code':
          iconData = Icons.code;
          break;
        case 'book':
          iconData = Iconsax.book_1;
          break;
        case 'exec':
          iconData = Iconsax.code;
          break;
        case 'web':
          iconData = Iconsax.chrome;
          break;
        case 'sheet':
          iconData = Iconsax.document_text;
          break;
        case 'text':
          iconData = Iconsax.document;
          break;
        case 'font':
          iconData = Iconsax.text_block;
          break;
      }

      return Icon(iconData);
    }

    void _askToDownload() {
      final dialogContent = Text('Save "${content.maskedName}" to local disk?');

      Get.dialog(AlertDialog(
        title: const Text('Download'),
        content: Utils.isDrawerExpandable
            ? dialogContent
            : SizedBox(width: 600, child: dialogContent),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
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
          leading: const Icon(Iconsax.import_1),
          onSelected: () => controller.restore(content),
        ),
        if (!controller.currentPath.value.contains('Backups/')) ...[
          ContextMenuItem(
            title: 'Backup',
            leading: const Icon(Iconsax.document_copy),
            onSelected: () => controller.backup(content),
          ),
        ]
      ] else ...[
        if (content.isFile) ...[
          ContextMenuItem(
            title: 'Download',
            leading: const Icon(Iconsax.import_1),
            onSelected: _askToDownload,
          ),
        ],
        // if (PersistenceService.to.syncProvider.val ==
        //     LisoSyncProvider.ipfs.name) ...[
        //   ContextMenuItem(
        //     title: 'Copy IPFS CID',
        //     leading: const Icon(Iconsax.copy),
        //     onSelected: () => Utils.copyToClipboard(content.object?.eTag),
        //   ),
        //   ContextMenuItem(
        //     title: 'Copy IPFS URL',
        //     leading: const Icon(Iconsax.copy),
        //     onSelected: () => Utils.copyToClipboard(content.object?.eTag),
        //   ),
        // ],
        ContextMenuItem(
          title: 'Delete',
          leading: const Icon(Iconsax.trash),
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
      iconColor: content.isFile ? themeColor : null,
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
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          child: Text('proceed'.tr),
          onPressed: () => controller.restore(s3content),
        ),
      ],
    ));
  }
}
