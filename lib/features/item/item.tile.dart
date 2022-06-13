import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/item/items.service.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/features/shared_vaults/shared_vault.controller.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/custom_chip.widget.dart';
import '../general/remote_image.widget.dart';
import '../json_viewer/json_viewer.screen.dart';
import '../menu/context.menu.dart';
import '../menu/menu.item.dart';
import '../shared_vaults/model/shared_vault.model.dart';

class ItemTile extends StatelessWidget with ConsoleMixin {
  final HiveLisoItem item;
  final bool searchMode;
  final bool joinedVaultItem;

  ItemTile(
    this.item, {
    Key? key,
    this.searchMode = false,
    this.joinedVaultItem = false,
  }) : super(key: key);

  void _open() async {
    if (item.protected && !(await _unlock())) return;

    // route parameters
    final parameters = {
      'mode': 'update',
      'category': item.category,
      'hiveKey': item.key.toString(),
      'identifier': item.identifier,
      'joinedVaultItem': joinedVaultItem.toString(),
    };

    Utils.adaptiveRouteOpen(name: Routes.item, parameters: parameters);
  }

  void _favorite() async {
    item.favorite = !item.favorite;
    item.metadata = await item.metadata.getUpdated();
    await item.save();
    MainScreenController.to.onItemsUpdated();
  }

  void _duplicate() async {
    final copy = HiveLisoItem.fromJson(item.toJson());
    copy.identifier = const Uuid().v4();
    copy.title = '${copy.title} Copy';
    copy.metadata = await copy.metadata.getUpdated();
    await ItemsService.to.box.add(copy);
    MainScreenController.to.onItemsUpdated();
  }

  void _restore() async {
    item.trashed = false;
    item.deleted = false;
    item.metadata = await item.metadata.getUpdated();
    await item.save();
    MainScreenController.to.onItemsUpdated();
  }

  void _trash() async {
    item.trashed = true;
    item.metadata = await item.metadata.getUpdated();
    // final m = await item.metadata.getUpdated();
    // m.updatedTime = DateTime.now().subtract(31.days);
    // item.metadata = m;
    await item.save();
    MainScreenController.to.onItemsUpdated();
  }

  void _delete() async {
    // if (!item.deleted) {
    //   item.deleted = true;
    //   item.metadata = await item.metadata.getUpdated();
    //   await item.save();
    // } else {
    //   item.fields = ItemsService.to.data.first.fields;
    //   item.metadata = await item.metadata.getUpdated();
    //   await item.save();
    // }

    item.fields = ItemsService.to.data[1].fields;
    item.metadata = await item.metadata.getUpdated();
    await item.save();

    MainScreenController.to.onItemsUpdated();
  }

  void _confirmDelete() async {
    const dialogContent = Text(
      'Are you sure you want to permanently delete this item?',
    );

    return Get.dialog(AlertDialog(
      title: Text('delete'.tr),
      content: Utils.isDrawerExpandable
          ? dialogContent
          : const SizedBox(
              width: 450,
              child: dialogContent,
            ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            _delete();
          },
          child: Text('delete'.tr),
        ),
      ],
    ));
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
      if (!joinedVaultItem) ...[
        if (item.trashed) ...[
          ContextMenuItem(
            title: 'restore'.tr,
            leading: const Icon(Iconsax.refresh),
            onSelected: _restore,
          ),
          ContextMenuItem(
            title: 'delete'.tr,
            leading: const Icon(Iconsax.trash),
            onSelected: _confirmDelete,
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
            title: 'duplicate'.tr,
            leading: const Icon(Iconsax.copy),
            onSelected: _duplicate,
          ),
          if (!item.reserved) ...[
            ContextMenuItem(
              title: 'move_to_trash'.tr,
              leading: const Icon(Iconsax.trash),
              onSelected: _trash,
            ),
          ],
        ],
      ],
      ContextMenuItem(
        title: 'details'.tr,
        leading: const Icon(Iconsax.code),
        // TODO: adaptive route for json viewer screen
        onSelected: () => Get.to(() => JSONViewerScreen(data: item.toJson())),
      ),
    ];

    final tags = item.tags
        .map(
          (e) => CustomChip(
            icon: const Icon(Iconsax.tag, size: 10),
            label: Text(
              e,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        )
        .toList();

    final sharedVaults = item.sharedVaultIds.map(
      (e) {
        final results = SharedVaultsController.to.data.where(
          (x) => x.docId == e,
        );

        SharedVault? vault;
        if (results.isNotEmpty) vault = results.first;
        Widget icon = const Icon(Iconsax.share, size: 10);

        if (vault?.iconUrl != null && vault!.iconUrl.isNotEmpty) {
          icon = RemoteImage(
            url: vault.iconUrl,
            width: 10,
            alignment: Alignment.centerLeft,
          );
        }

        return CustomChip(
          icon: icon,
          color: Colors.amber.withOpacity(0.3),
          label: Text(
            vault?.name ?? e,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
        );
      },
    ).toList();

    final bottomSubTitle = Wrap(
      runSpacing: 5,
      children: [
        if (item.favorite) ...[
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Iconsax.heart, color: Colors.pink, size: 10),
          ),
          const SizedBox(width: 5),
        ],
        if (item.protected) ...[
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(Iconsax.shield_tick, color: themeColor, size: 10),
          ),
          const SizedBox(width: 5),
        ],
        if (item.attachments.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Iconsax.attach_circle, color: null, size: 10),
          ),
          const SizedBox(width: 5),
        ],
        if (item.reserved) ...[
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Iconsax.key, color: Colors.lightBlue, size: 10),
          ),
          const SizedBox(width: 5),
        ],
        if (item.tags.isNotEmpty) ...[
          ...tags,
        ],
        if (item.sharedVaultIds.isNotEmpty) ...[
          ...sharedVaults,
        ],
        Text(
          item.updatedTimeAgo,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        if (item.trashed) ...[
          const SizedBox(width: 5),
          Text(
            '${item.daysLeftToDelete} days left till ',
            style: const TextStyle(fontSize: 10, color: Colors.red),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Iconsax.trash, color: Colors.red, size: 10),
          ),
        ]
      ],
    );

    final subTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.subTitle.trim().isNotEmpty) ...[
          Text(item.subTitle, overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 5),
        ],
        bottomSubTitle,
      ],
    );

    final leading = item.iconUrl.isNotEmpty
        ? RemoteImage(
            url: item.iconUrl,
            width: 35,
            alignment: Alignment.centerLeft,
          )
        : Utils.categoryIcon(item.category, color: themeColor);

    var tile = ListTile(
      selected: item.deleted,
      selectedColor: item.deleted ? Colors.red : null,
      leading: leading,
      subtitle: subTitle,
      title: Text(
        item.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: ContextMenuButton(
        menuItems,
        child: const Icon(LineIcons.verticalEllipsis),
      ),
      onLongPress:
          isLargeScreen ? null : () => ContextMenuSheet(menuItems).show(),
      onTap: _open,
    );

    if (isLargeScreen) return tile;

    // if small screen, add swipe actions
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

    return SwipeActionCell(
      key: ObjectKey(item),
      leadingActions: leadingActions,
      trailingActions: trailingActions,
      child: tile,
    );
  }
}
