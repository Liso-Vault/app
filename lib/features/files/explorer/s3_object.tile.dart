import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/files/explorer/s3_exporer_screen.controller.dart';
import 'package:liso/features/files/explorer/s3_object_tile.controller.dart';

import '../../../core/utils/globals.dart';
import '../../../core/utils/utils.dart';
import '../../menu/menu.button.dart';
import '../../menu/menu.item.dart';
import '../../supabase/model/object.model.dart';

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
          title: 'Switch',
          leading: Icon(Iconsax.import_1, size: popupIconSize),
          onSelected: () => controller.confirmSwitch(object),
        ),
        // if (!explorerController.currentPath.value.contains('$kDirBackups/')) ...[
        //   ContextMenuItem(
        //     title: 'Backup',
        //     leading: Icon(Iconsax.document_copy, size: popupIconSize),
        //     onSelected: () => controller.backup(content),
        //   ),
        // ]
      ] else ...[
        if (object.isFile && !isPicker) ...[
          ContextMenuItem(
            title: 'Download',
            leading: Icon(Iconsax.import_1, size: popupIconSize),
            onSelected: () => controller.confirmDownload(object),
          ),
          ContextMenuItem(
            title: 'Share',
            leading: Icon(Iconsax.share, size: popupIconSize),
            onSelected: () => controller.share(object),
          ),
        ],
        ContextMenuItem(
          title: 'Delete',
          leading: Icon(Iconsax.trash, size: popupIconSize),
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
      if (!object.isFile) {
        return explorerController.navigate(prefix: object.key);
      }

      if (isPicker) return Get.back(result: object.etag);

      if (object.isVaultFile) {
        controller.confirmSwitch(object);
      } else {
        controller.confirmDownload(object);
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
        // subtitle: Text(
        //   object.key.replaceAll('${SecretPersistence.to.walletAddress.val}/', ''),
        // ),
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
