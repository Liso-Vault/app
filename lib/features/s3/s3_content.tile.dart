import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/s3/s3_exporer_screen.controller.dart';

import '../../core/utils/console.dart';
import '../../core/utils/globals.dart';
import '../main/main_screen.controller.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'model/s3_content.model.dart';

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
    ];

    return ListTile(
      title: Text(content.name),
      subtitle: Text(content.path),
      iconColor: content.isFile ? kAppColor : null,
      leading: Icon(
        content.isFile ? LineIcons.fileAlt : LineIcons.folderOpen,
      ),
      trailing: content.isFile
          ? ContextMenuButton(
              menuItems,
              child: const Icon(LineIcons.verticalEllipsis),
            )
          : null,
      onTap: () {
        if (content.isFile) {
          _askToImport(content);
        } else {
          controller.load(path: content.path);
        }
      },
    );
  }

  void _askToImport(S3Content s3content) {
    final content = RichText(
      text: TextSpan(
        text: 'Are you sure you want to restore vault with hash: ',
        style: Get.theme.dialogTheme.contentTextStyle,
        children: <TextSpan>[
          TextSpan(
            text: s3content.name,
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
      content: MainScreenController.to.expandableDrawer
          ? content
          : SizedBox(
              width: 600,
              child: content,
            ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: Get.back,
          style: TextButton.styleFrom(),
        ),
        TextButton(
          child: const Text('Proceed'),
          onPressed: () => controller.restore(s3content),
        ),
      ],
    ));
  }
}
