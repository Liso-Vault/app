import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/s3/explorer/s3_exporer_screen.controller.dart';

import '../../../core/utils/globals.dart';
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
            onSelected: () => controller.askToDownload(content),
          ),
          ContextMenuItem(
            title: 'Share',
            leading: const Icon(Iconsax.share),
            onSelected: () => controller.share(content),
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

    return ListTile(
      title: Text(content.maskedName),
      subtitle: subTitle,
      iconColor: themeColor,
      leading: controller.leadingIcon(content),
      trailing: ContextMenuButton(
        menuItems,
        child: const Icon(LineIcons.verticalEllipsis),
      ),
      onTap: () {
        if (content.isFile) {
          if (content.isVaultFile) {
            controller.askToImport(content);
          } else {
            controller.askToDownload(content);
          }
        } else {
          controller.load(path: content.path);
        }
      },
    );
  }
}
