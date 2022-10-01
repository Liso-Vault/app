import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/supabase/model/object.model.dart';
import 'package:liso/features/files/explorer/s3_exporer_screen.controller.dart';
import 'package:liso/features/files/explorer/s3_object_tile.controller.dart';
import 'package:secrets/secrets.dart';

import '../../../core/persistence/persistence.secret.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/utils.dart';
import '../../menu/menu.button.dart';
import '../../menu/menu.item.dart';

class S3ObjectTile extends GetWidget<S3ObjectTileController> with ConsoleMixin {
  final S3Object object;

  const S3ObjectTile(
    this.object, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPicker = Get.parameters['type'] == 'picker';
    final explorerController = Get.find<S3ExplorerScreenController>();

    final menuItems = [
      if (object.isVaultFile && !isPicker) ...[
        ContextMenuItem(
          title: 'Restore',
          leading: const Icon(Iconsax.import_1),
          onSelected: () => controller.restore(object),
        ),
        // if (!explorerController.currentPath.value.contains('Backups/')) ...[
        //   ContextMenuItem(
        //     title: 'Backup',
        //     leading: const Icon(Iconsax.document_copy),
        //     onSelected: () => controller.backup(content),
        //   ),
        // ]
      ] else ...[
        if (object.isFile && !isPicker) ...[
          ContextMenuItem(
            title: 'Download',
            leading: const Icon(Iconsax.import_1),
            onSelected: () => controller.askToDownload(object),
          ),
          ContextMenuItem(
            title: 'Share',
            leading: const Icon(Iconsax.share),
            onSelected: () => controller.share(object),
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
          onSelected: () => controller.confirmDelete(object),
        ),
      ],
    ];

    final subTitle = object.size > 0
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(filesize(object.size)),
                  if (object.isEncrypted) ...[
                    const SizedBox(width: 10),
                    Icon(Iconsax.shield_tick, color: themeColor, size: 10)
                  ],
                ],
              ),
              Text(object.updatedTimeAgo),
            ],
          )
        : null;

    void open() {
      if (object.isFile) {
        if (isPicker) {
          return Get.back(result: object.etag);
        }

        if (object.isVaultFile) {
          controller.askToImport(object);
        } else {
          controller.askToDownload(object);
        }
      } else {
        explorerController.navigate(prefix: object.key);
      }
    }

    return Obx(
      () => ListTile(
        title: Text(
          object.maskedName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: controller.busy.value ? Text(controller.state) : subTitle,
        iconColor: themeColor,
        leading: Utils.s3ContentIcon(object),
        enabled: !controller.busy.value,
        onTap: open,
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
      ),
    );
  }
}
