import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/utils/console.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/custom_chip.widget.dart';
import '../general/selector.sheet.dart';
import '../json_viewer/json_viewer.screen.dart';
import 'drawer/drawer_widget.controller.dart';

class ItemTile extends StatelessWidget with ConsoleMixin {
  final HiveLisoItem item;
  final bool searchMode;

  const ItemTile(
    this.item, {
    Key? key,
    this.searchMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerController = Get.find<DrawerWidgetController>();

    final isArchived = drawerController.boxFilter == HiveBoxFilter.archived;
    final isTrash = drawerController.boxFilter == HiveBoxFilter.trash;

    void _favorite() {
      item.favorite = !item.favorite;
      item.save();
    }

    void _archive() async {
      item.delete();
      await HiveManager.archived!.add(item);
    }

    void _trash() async {
      item.delete();
      await HiveManager.trash!.add(item);
    }

    void _restore() async {
      item.delete();
      await HiveManager.items!.add(item);
    }

    void contextMenu() {
      SelectorSheet(
        items: [
          SelectorItem(
            title: item.favorite ? 'unfavorite'.tr : 'favorite'.tr,
            leading: Icon(
              item.favorite ? LineIcons.heartAlt : LineIcons.heart,
              color: item.favorite ? Colors.red : Get.theme.iconTheme.color,
            ),
            onSelected: _favorite,
          ),
          if (!isArchived) ...[
            SelectorItem(
              title: isTrash ? 'move_to_archive'.tr : 'archive'.tr,
              leading: const Icon(LineIcons.archive),
              onSelected: _archive,
            ),
          ],
          if (!isTrash) ...[
            SelectorItem(
              title: isArchived ? 'move_to_trash'.tr : 'trash'.tr,
              leading: const Icon(LineIcons.trash),
              onSelected: _trash,
            ),
          ],
          if (isTrash || isArchived) ...[
            SelectorItem(
              title: 'restore'.tr,
              leading: const Icon(LineIcons.trashRestore),
              onSelected: _restore,
            ),
          ],
          SelectorItem(
            title: 'details'.tr,
            subTitle: 'In JSON format',
            leading: const Icon(LineIcons.code),
            onSelected: () =>
                Get.to(() => JSONViewerScreen(data: item.toJson())),
          ),
        ],
      ).show();
    }

    final title = Text(
      item.title,
      overflow: TextOverflow.ellipsis,
    );

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

    final trailing = searchMode || GetPlatform.isMobile
        ? null
        : IconButton(
            onPressed: contextMenu,
            icon: const Icon(LineIcons.verticalEllipsis),
          );

    final tile = ListTile(
      leading: Utils.categoryIcon(
        LisoItemCategory.values.byName(item.category),
      ),
      title: title,
      subtitle: subTitle,
      trailing: trailing,
      onLongPress: searchMode || !GetPlatform.isMobile ? null : contextMenu,
      onTap: () => Get.toNamed(Routes.item, parameters: {
        'mode': 'update',
        'category': item.category,
        'hiveKey': item.key.toString(),
      }),
    );

    final swipeAction = SwipeActionCell(
      key: ObjectKey(item),
      child: tile,
      leadingActions: <SwipeAction>[
        SwipeAction(
          title: item.favorite ? 'unfavorite'.tr : 'favorite'.tr,
          color: Colors.pink,
          widthSpace: 100,
          performsFirstActionWithFullSwipe: true,
          icon: Icon(item.favorite ? LineIcons.heartAlt : LineIcons.heart),
          style: const TextStyle(fontSize: 15),
          onTap: (CompletionHandler handler) async {
            await handler(false);
            _favorite();
          },
        ),
        if (isTrash || isArchived) ...[
          SwipeAction(
            title: 'restore'.tr,
            color: Colors.green,
            icon: const Icon(LineIcons.trashRestore),
            style: const TextStyle(fontSize: 15),
            onTap: (CompletionHandler handler) async {
              await handler(true);
              _restore();
            },
          ),
        ],
      ],
      trailingActions: <SwipeAction>[
        if (!isTrash) ...[
          SwipeAction(
            title: 'trash'.tr,
            color: Colors.red,
            icon: const Icon(LineIcons.trash),
            style: const TextStyle(fontSize: 15),
            performsFirstActionWithFullSwipe: true,
            onTap: (CompletionHandler handler) async {
              await handler(true);
              _trash();
            },
          ),
        ],
        if (!isArchived) ...[
          SwipeAction(
            title: 'archive'.tr,
            color: Colors.orange,
            icon: const Icon(LineIcons.archive),
            style: const TextStyle(fontSize: 15),
            onTap: (CompletionHandler handler) async {
              await handler(true);
              _archive();
            },
          ),
        ],
      ],
    );

    return GestureDetector(
      onSecondaryTap: searchMode ? null : contextMenu, // mouse right click
      // TODO: production
      // child: GetPlatform.isMobile && !searchMode ? swipeAction : tile,
      child: swipeAction,
    );
  }
}
