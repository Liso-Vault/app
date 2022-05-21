import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:uuid/uuid.dart';

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
    MainScreenController.to.onItemsUpdated();
  }

  void _delete() {
    item.delete();
    MainScreenController.to.onItemsUpdated();
  }

  void _trash() async {
    item.trashed = true;
    item.metadata = await item.metadata.getUpdated();
    item.save();
    MainScreenController.to.onItemsUpdated();
  }

  void _restore() async {
    item.trashed = false;
    item.metadata = await item.metadata.getUpdated();
    item.save();
    MainScreenController.to.onItemsUpdated();
  }

  void _duplicate() async {
    final copy = HiveLisoItem.fromJson(item.toJson());
    copy.identifier = const Uuid().v4();
    copy.title = '${copy.title} Copy';
    copy.metadata = await copy.metadata.getUpdated();
    HiveManager.items!.add(copy);
    MainScreenController.to.onItemsUpdated();
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

    return unlocked;
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !Utils.isDrawerExpandable;

    final menuItems = [
      if (item.trashed) ...[
        ContextMenuItem(
          title: 'restore'.tr,
          leading: const Icon(Iconsax.refresh),
          onSelected: _restore,
        ),
        ContextMenuItem(
          title: 'delete_permanently'.tr,
          leading: const Icon(Iconsax.trash),
          onSelected: _delete,
        ),
      ] else ...[
        ContextMenuItem(
          title: item.favorite ? 'unfavorite'.tr : 'favorite'.tr,
          leading: FaIcon(
            item.favorite ? Iconsax.heart_remove : Iconsax.heart_add,
            color: item.favorite ? Colors.pink : themeColor,
          ),
          onSelected: _favorite,
        ),
        ContextMenuItem(
          title: 'move_to_trash'.tr,
          leading: const Icon(Iconsax.trash),
          onSelected: _trash,
        ),
        ContextMenuItem(
          title: 'duplicate'.tr,
          leading: const Icon(Iconsax.copy),
          onSelected: _duplicate,
        ),
      ],
      ContextMenuItem(
        title: 'details'.tr,
        leading: const Icon(Iconsax.code),
        // TODO: adaptive route for json viewer screen
        onSelected: () => Get.to(() => JSONViewerScreen(data: item.toJson())),
      ),
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
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: FaIcon(
                  FontAwesomeIcons.solidHeart,
                  color: Colors.pink,
                  size: 10,
                ),
              ),
              const SizedBox(width: 5),
            ],
            if (item.protected) ...[
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: FaIcon(
                  FontAwesomeIcons.shield,
                  color: themeColor,
                  size: 10,
                ),
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
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            if (item.trashed) ...[
              Text(
                ' 🗑  ${item.daysLeftToDelete} days left',
                style: const TextStyle(fontSize: 10, color: Colors.red),
              ),
            ]
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
            color: themeColor,
          );

    var tile = ListTile(
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
    final leadingActions = <SwipeAction>[
      SwipeAction(
        title: item.favorite ? 'unfavorite'.tr : 'favorite'.tr,
        color: Colors.pink,
        widthSpace: 100,
        performsFirstActionWithFullSwipe: true,
        icon: Icon(
          item.favorite ? Iconsax.heart5 : Iconsax.heart,
          color: Colors.white,
        ),
        style: const TextStyle(fontSize: 15, color: Colors.white),
        onTap: (CompletionHandler handler) async {
          await handler(false);
          _favorite();
        },
      ),
      if (item.trashed) ...[
        SwipeAction(
          title: 'restore'.tr,
          color: themeColor,
          icon: const Icon(
            Iconsax.refresh,
            color: Colors.white,
          ),
          style: const TextStyle(fontSize: 15, color: Colors.white),
          onTap: (CompletionHandler handler) async {
            await handler(true);
            _restore();
          },
        ),
      ],
    ];

    final trailingActions = <SwipeAction>[
      SwipeAction(
        title: item.trashed ? 'delete_permanently'.tr : 'trash'.tr,
        color: Colors.red,
        icon: const Icon(Iconsax.trash, color: Colors.white),
        style: const TextStyle(fontSize: 15, color: Colors.white),
        performsFirstActionWithFullSwipe: true,
        onTap: (CompletionHandler handler) async {
          await handler(true);
          item.trashed ? _delete() : _trash();
        },
      ),
    ];

    final swipeAction = SwipeActionCell(
      key: ObjectKey(item),
      leadingActions: leadingActions,
      trailingActions: trailingActions,
      child: tile,
    );

    return swipeAction;
  }
}
