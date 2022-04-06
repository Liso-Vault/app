import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/main/main_screen.controller.dart';

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
    final mainController = Get.find<MainScreenController>();

    final isArchived =
        drawerController.boxFilter.value == HiveBoxFilter.archived;
    final isTrash = drawerController.boxFilter.value == HiveBoxFilter.trash;

    void _reloadSearchDelegate() {
      mainController.searchDelegate?.reload(context);
    }

    void _favorite() {
      item.favorite = !item.favorite;
      item.save();
      _reloadSearchDelegate();
    }

    void _protect() async {
      if (item.protected) {
        // if trying to unprotect, prompt password
        final unlocked = await Get.toNamed(
              Routes.unlock,
              parameters: {'mode': 'password_prompt'},
            ) ??
            false;

        if (!unlocked) return;
      }

      item.protected = !item.protected;
      item.save();
      _reloadSearchDelegate();
    }

    void _archive() async {
      item.delete();
      await HiveManager.archived!.add(item);
      _reloadSearchDelegate();
    }

    void _trash() async {
      // TODO: prompt to delete with selector sheet
      item.delete();
      await HiveManager.trash!.add(item);
      _reloadSearchDelegate();
    }

    void _restore() async {
      item.delete();
      await HiveManager.items!.add(item);
      _reloadSearchDelegate();
    }

    void _open() async {
      if (item.protected) {
        final unlocked = await Get.toNamed(
              Routes.unlock,
              parameters: {'mode': 'password_prompt'},
            ) ??
            false;

        if (!unlocked) return;
      }

      Get.toNamed(Routes.item, parameters: {
        'mode': 'update',
        'category': item.category,
        'hiveKey': item.key.toString(),
      });
    }

    void menu() {
      SelectorSheet(
        items: [
          SelectorItem(
            title: item.favorite ? 'unfavorite'.tr : 'favorite'.tr,
            leading: FaIcon(
              item.favorite
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart,
              color: item.favorite ? Colors.pink : null,
            ),
            onSelected: _favorite,
          ),
          SelectorItem(
            title: item.protected ? 'unprotect'.tr : 'protect'.tr,
            leading: FaIcon(
              item.protected
                  ? FontAwesomeIcons.shield
                  : FontAwesomeIcons.shieldHalved,
              color: item.protected ? kAppColor : null,
            ),
            onSelected: _protect,
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
        if (item.subTitle.isNotEmpty) ...[
          Text(
            item.subTitle,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
        ],
        Wrap(
          runSpacing: 5,
          children: [
            if (item.favorite) ...[
              const FaIcon(
                FontAwesomeIcons.solidHeart,
                color: Colors.pink,
                size: 10,
              ),
              const SizedBox(width: 5),
            ],
            if (item.protected) ...[
              const FaIcon(FontAwesomeIcons.shield, color: kAppColor, size: 10),
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

    final trailing = IconButton(
      onPressed: menu,
      icon: const Icon(LineIcons.verticalEllipsis),
    );

    final leading = item.icon.isNotEmpty
        ? Image.memory(
            item.icon,
            width: 35,
            alignment: Alignment.centerLeft,
          )
        : Utils.categoryIcon(
            LisoItemCategory.values.byName(item.category),
          );

    final tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subTitle,
      trailing: trailing,
      onLongPress: menu,
      onTap: _open,
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
          icon: FaIcon(item.favorite
              ? FontAwesomeIcons.solidHeart
              : FontAwesomeIcons.heart),
          style: const TextStyle(fontSize: 15),
          onTap: (CompletionHandler handler) async {
            await handler(false);
            _favorite();
          },
        ),
        if (isTrash || isArchived) ...[
          SwipeAction(
            title: 'restore'.tr,
            color: kAppColor,
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
      onSecondaryTap: menu, // mouse right click
      child: swipeAction,
    );
  }
}
