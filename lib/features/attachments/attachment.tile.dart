import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';

import '../../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import '../s3/model/s3_content.model.dart';

class AttachmentTile extends StatelessWidget with ConsoleMixin {
  final S3Content content;
  final Function()? onDelete;

  const AttachmentTile(
    this.content, {
    this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      ContextMenuItem(
        title: 'Remove',
        leading: const Icon(Iconsax.trash),
        onSelected: onDelete,
      ),
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
      leading: Utils.s3ContentIcon(content),
      // onTap: () => Get.back(result: content.object!.eTag),
      trailing: ContextMenuButton(
        menuItems,
        child: const Icon(LineIcons.verticalEllipsis),
      ),
    );
  }
}
