import 'package:app_core/globals.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';

import '../../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import '../supabase/model/object.model.dart';

class AttachmentTile extends StatelessWidget with ConsoleMixin {
  final S3Object object;
  final Function()? onDelete;

  const AttachmentTile(
    this.object, {
    this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      ContextMenuItem(
        title: 'Remove',
        leading: Icon(Iconsax.trash, size: popupIconSize),
        onSelected: onDelete,
      ),
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

    return ListTile(
      title: Text(object.maskedName),
      subtitle: subTitle,
      iconColor: themeColor,
      leading: AppUtils.s3ContentIcon(object),
      // onTap: () => Get.back(result: content.object!.eTag),
      trailing: ContextMenuButton(
        menuItems,
        child: const Icon(LineIcons.verticalEllipsis),
      ),
    );
  }
}
