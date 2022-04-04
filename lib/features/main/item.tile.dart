import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/item.hive.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/custom_chip.widget.dart';
import '../general/selector.sheet.dart';
import '../json_viewer/json_viewer.screen.dart';
import 'drawer/drawer_widget.controller.dart';

class ItemTile extends StatelessWidget {
  final HiveLisoItem item;
  final bool searchMode;

  const ItemTile(
    this.item, {
    Key? key,
    this.searchMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.subTitle,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            if (item.favorite) ...[
              const Icon(
                LineIcons.heartAlt,
                color: Colors.red,
                size: 15,
              ),
              const SizedBox(width: 5),
            ],
            if (item.tags.isNotEmpty) ...[
              ...item.tags
                  .map(
                    (e) => CustomChip(
                      label: Text(
                        e,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  )
                  .toList(),
              const SizedBox(width: 5),
            ],
            Text(
              item.updatedTimeAgo,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        )
      ],
    );

    return GestureDetector(
      // on mouse right click
      onSecondaryTap: searchMode ? null : contextMenu,
      child: ListTile(
        leading: Utils.categoryIcon(
          LisoItemCategory.values.byName(item.category),
        ),
        title: Text(
          item.title,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subTitle,
        trailing: searchMode
            ? null
            : IconButton(
                onPressed: contextMenu,
                icon: const Icon(LineIcons.verticalEllipsis),
              ),
        onLongPress: searchMode ? null : contextMenu,
        onTap: () => Get.toNamed(Routes.item, parameters: {
          'mode': 'update',
          'category': item.category,
          'hiveKey': item.key.toString(),
        }),
      ),
    );
  }

  void contextMenu() {
    final drawerController = Get.find<DrawerWidgetController>();

    final isArchived = drawerController.boxFilter == HiveBoxFilter.archived;
    final isTrash = drawerController.boxFilter == HiveBoxFilter.trash;

    SelectorSheet(
      items: [
        SelectorItem(
          title: item.favorite ? 'unfavorite'.tr : 'favorite'.tr,
          leading: Icon(
            item.favorite ? LineIcons.heartAlt : LineIcons.heart,
            color: item.favorite ? Colors.red : Get.theme.iconTheme.color,
          ),
          onSelected: () {
            item.favorite = !item.favorite;
            item.save();
          },
        ),
        if (!isArchived) ...[
          SelectorItem(
            title: isTrash ? 'move_to_archive'.tr : 'archive'.tr,
            leading: const Icon(LineIcons.archive),
            onSelected: () async {
              item.delete();
              await HiveManager.archived!.add(item);
            },
          ),
        ],
        if (!isTrash) ...[
          SelectorItem(
            title: isArchived ? 'move_to_trash'.tr : 'trash'.tr,
            leading: const Icon(LineIcons.trash),
            onSelected: () async {
              item.delete();
              await HiveManager.trash!.add(item);
            },
          ),
        ],
        if (isTrash || isArchived) ...[
          SelectorItem(
            title: 'restore'.tr,
            leading: const Icon(LineIcons.trashRestore),
            onSelected: () async {
              item.delete();
              await HiveManager.items!.add(item);
            },
          ),
        ],
        SelectorItem(
          title: 'details'.tr,
          subTitle: 'In JSON format',
          leading: const Icon(LineIcons.code),
          onSelected: () => Get.to(() => JSONViewerScreen(data: item.toJson())),
        ),
      ],
    ).show();
  }
}
