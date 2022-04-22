import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/custom_chip.widget.dart';
import '../general/remote_image.widget.dart';
import '../json_viewer/json_viewer.screen.dart';
import '../menu/context.menu.dart';
import '../menu/menu.item.dart';

class ItemTile extends StatelessWidget with ConsoleMixin {
  final HiveLisoItem item;
  final bool searchMode;

  ItemTile(
    this.item, {
    Key? key,
    this.searchMode = false,
  }) : super(key: key);

  void _favorite() async {
    item.favorite = !item.favorite;
    item.metadata = await item.metadata.getUpdated();
    item.save();
  }

  // void _protect() async {
  //   if (item.protected && !(await _unlock())) return;
  //   item.protected = !item.protected;
  //   item.metadata = await item.metadata.getUpdated();
  //   item.save();
  //   _reloadSearchDelegate();
  // }

  void _delete() {
    item.delete();
    MainScreenController.to.load();
  }

  void _trash() async {
    item.trashed = !item.trashed;
    item.metadata = await item.metadata.getUpdated();
    item.save();
    // _reloadSearchDelegate();
  }

  void _restore() {
    item.delete();
    HiveManager.items!.add(item);
  }

  void _open() async {
    if (item.protected && !(await _unlock())) return;

    // route parameters
    final parameters = {
      'mode': 'update',
      'category': item.category,
      'hiveKey': item.key.toString(),
    };

    Utils.adaptiveRouteOpen(
      name: Routes.item,
      parameters: parameters,
    );
  }

  // show lock screen if item is protected
  Future<bool> _unlock() async {
    final unlocked = await Get.toNamed(
          Routes.unlock,
          parameters: {'mode': 'password_prompt'},
        ) ??
        false;

    if (!unlocked) console.warning('failed to unlock');

    return unlocked;
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !Utils.isDrawerExpandable;

    final menuItems = [
      ContextMenuItem(
        title: item.favorite ? 'unfavorite'.tr : 'favorite'.tr,
        leading: FaIcon(
          item.favorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
          color: item.favorite ? Colors.pink : null,
        ),
        onSelected: _favorite,
      ),
      // ContextMenuItem(
      //   title: item.protected ? 'unprotect'.tr : 'protect'.tr,
      //   leading: FaIcon(
      //     item.protected
      //         ? FontAwesomeIcons.shield
      //         : FontAwesomeIcons.shieldHalved,
      //     color: item.protected ? kAppColor : null,
      //   ),
      //   function: _protect,
      // ),
      ContextMenuItem(
        title: 'details'.tr,
        leading: const Icon(LineIcons.code),
        // TODO: adaptive route for json viewer screen
        onSelected: () => Get.to(() => JSONViewerScreen(data: item.toJson())),
      ),
      if (item.trashed) ...[
        ContextMenuItem(
          title: 'restore'.tr,
          leading: const Icon(LineIcons.trashRestore),
          onSelected: _restore,
        ),
        ContextMenuItem(
          title: 'delete_permanently'.tr,
          leading: const Icon(LineIcons.trash),
          onSelected: _delete,
        ),
      ] else ...[
        ContextMenuItem(
          title: 'move_to_trash'.tr,
          leading: const Icon(LineIcons.trash),
          onSelected: _trash,
        ),
      ],
    ];

    final title = Text(
      item.title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    final subTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.subTitle.isNotEmpty) ...[
          Text(
            item.subTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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

    final leading = item.iconUrl.isNotEmpty
        ? RemoteImage(
            url: item.iconUrl,
            width: 35,
            alignment: Alignment.centerLeft,
          )
        : Utils.categoryIcon(
            LisoItemCategory.values.byName(item.category),
          );

    Widget tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subTitle,
      trailing: ContextMenuButton(
        menuItems,
        child: const Icon(LineIcons.verticalEllipsis),
      ),
      onLongPress:
          isLargeScreen ? null : () => ContextMenuSheet(menuItems).show(),
      onTap: _open,
    );

    // if large screen
    if (isLargeScreen) return tile;

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
        if (item.trashed) ...[
          SwipeAction(
            title: 'restore'.tr,
            color: kAppColorDarker,
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
        SwipeAction(
          title: item.trashed ? 'delete_permanently'.tr : 'trash'.tr,
          color: Colors.red,
          icon: const Icon(LineIcons.trash),
          style: const TextStyle(fontSize: 15),
          performsFirstActionWithFullSwipe: true,
          onTap: (CompletionHandler handler) async {
            await handler(true);

            if (item.trashed) {
              _delete();
            } else {
              _trash();
            }
          },
        ),
      ],
    );

    return swipeAction;
  }
}
