import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/s3/explorer/s3_content_tile.controller.dart';
import 'package:liso/features/s3/explorer/s3_exporer_screen.controller.dart';

import '../../../core/utils/globals.dart';
import '../../../core/utils/utils.dart';
import '../../menu/menu.button.dart';
import '../../menu/menu.item.dart';
import '../model/s3_content.model.dart';

class S3ContentTile extends GetWidget<S3ContentTileController>
    with ConsoleMixin {
  final S3Content content;

  const S3ContentTile(
    this.content, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPicker = Get.parameters['type'] == 'picker';
    final explorerController = Get.find<S3ExplorerScreenController>();

    final menuItems = [
      if (content.isVaultFile && !isPicker) ...[
        ContextMenuItem(
          title: 'Restore',
          leading: const Icon(Iconsax.import_1),
          onSelected: () => controller.restore(content),
        ),
        // if (!explorerController.currentPath.value.contains('Backups/')) ...[
        //   ContextMenuItem(
        //     title: 'Backup',
        //     leading: const Icon(Iconsax.document_copy),
        //     onSelected: () => controller.backup(content),
        //   ),
        // ]
      ] else ...[
        if (content.isFile && !isPicker) ...[
          ContextMenuItem(
            title: 'Download',
            leading: const Icon(Iconsax.import_1),
            onSelected: () => controller.askToDownload(content),
          ),
          ContextMenuItem(
            title: 'Share',
            leading: const Icon(Iconsax.share),
            onSelected: () => controller.share(content),
          ),
        ],
        // if (Persistence.to.syncProvider.val ==
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

    final subTitle = content.size > 0
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(filesize(content.size)),
                  if (content.isEncrypted) ...[
                    const SizedBox(width: 10),
                    Icon(Iconsax.shield_tick, color: themeColor, size: 10)
                  ],
                ],
              ),
              if (content.object != null) Text(content.updatedTimeAgo),
            ],
          )
        : null;

    void _open() {
      if (content.isFile) {
        if (isPicker) {
          return Get.back(result: content.object!.eTag);
        }

        if (content.isVaultFile) {
          controller.askToImport(content);
        } else {
          controller.askToDownload(content);
        }
      } else {
        explorerController.load(path: content.path);
      }
    }

    return Obx(
      () => ListTile(
        title: Text(
          content.maskedName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: controller.busy.value ? Text(controller.state) : subTitle,
        iconColor: themeColor,
        leading: Utils.s3ContentIcon(content),
        enabled: !controller.busy.value,
        onTap: _open,
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
      ),
    );
  }
}
