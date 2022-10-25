import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/features/autofill/autofill.service.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/features/shared_vaults/shared_vault.controller.dart';
import 'package:uuid/uuid.dart';

import '../../core/persistence/persistence.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/custom_chip.widget.dart';
import '../json_viewer/json_viewer.screen.dart';
import '../menu/menu.item.dart';
import '../menu/menu.sheet.dart';
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
    if (isAutofill) {
      return LisoAutofillService.to.fill(item);
    }

    if (item.protected && !(await _unlock())) return;
    // if newly opened and hive hasn't finished init
    if (item.key == null) return console.error('key is null');

    // route parameters
    final parameters = {
      'mode': 'view',
      'category': item.category,
      'hiveKey': item.key.toString(),
      'identifier': item.identifier,
      'joinedVaultItem': joinedVaultItem.toString(),
    };

    Utils.adaptiveRouteOpen(name: AppRoutes.item, parameters: parameters);
  }

  void _favorite() async {
    item.favorite = !item.favorite;
    item.metadata = await item.metadata.getUpdated();
    await item.save();
    AppPersistence.to.changes.val++;
    ItemsController.to.load();
  }

  void _duplicate() async {
    final copy = HiveLisoItem.fromJson(item.toJson());
    copy.identifier = const Uuid().v4();
    copy.title = '${copy.title} Copy';
    copy.metadata = await copy.metadata.getUpdated();
    await ItemsService.to.box!.add(copy);
    AppPersistence.to.changes.val++;
    ItemsController.to.load();
  }

  void _restore() async {
    item.trashed = false;
    item.deleted = false;
    item.metadata = await item.metadata.getUpdated();
    await item.save();
    AppPersistence.to.changes.val++;
    ItemsController.to.load();
  }

  void _trash() async {
    item.trashed = true;
    item.metadata = await item.metadata.getUpdated();
    await item.save();
    AppPersistence.to.changes.val++;
    ItemsController.to.load();
  }

  void _delete() async {
    item.deleted = true;
    item.metadata = await item.metadata.getUpdated();
    await item.save();
    AppPersistence.to.changes.val++;
    ItemsController.to.load();
  }

  void _permaDelete() async {
    AppPersistence.to.addToDeletedItems(item.identifier);
    AppPersistence.to.changes.val++;
    await item.delete();
    ItemsController.to.load();
  }

  void _confirmDelete() async {
    const dialogContent = Text(
      'Are you sure you want to permanently delete this item?',
    );

    return Get.dialog(AlertDialog(
      title: Text('delete'.tr),
      content: isSmallScreen
          ? dialogContent
          : const SizedBox(width: 450, child: dialogContent),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () {
            Get.back();

            if (!item.deleted) {
              _delete();
            } else {
              _permaDelete();
            }
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
          parameters: {
            'mode': 'password_prompt',
            'reason': 'Protected Item',
          },
        ) ??
        false;

    return unlocked;
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !isSmallScreen;

    final menuItems = [
      if (!joinedVaultItem) ...[
        if (item.trashed) ...[
          ContextMenuItem(
            title: 'restore'.tr,
            leading: Icon(Iconsax.refresh, size: popupIconSize),
            onSelected: _restore,
          ),
          if (!item.deleted) ...[
            ContextMenuItem(
              title: 'delete'.tr,
              leading: Icon(Iconsax.trash, size: popupIconSize),
              onSelected: _confirmDelete,
            ),
          ] else ...[
            ContextMenuItem(
              title: 'Permanent Delete',
              leading: Icon(Iconsax.trash, size: popupIconSize),
              onSelected: _confirmDelete,
            ),
          ]
        ] else ...[
          ContextMenuItem(
            title: item.favorite ? 'unfavorite'.tr : 'favorite'.tr,
            leading: FaIcon(
              item.favorite ? Iconsax.heart_remove : Iconsax.heart_add,
              color: item.favorite ? Colors.pink : themeColor,
              size: popupIconSize,
            ),
            onSelected: _favorite,
          ),
          if (!item.reserved) ...[
            ContextMenuItem(
              title: 'duplicate'.tr,
              leading: Icon(Iconsax.copy, size: popupIconSize),
              onSelected: _duplicate,
            ),
            ContextMenuItem(
              title: 'move_to_trash'.tr,
              leading: Icon(Iconsax.trash, size: popupIconSize),
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

    const kIconSize = 10.0;
    final tags = item.tags.map(
      (e) => CustomChip(
        icon: const Icon(Iconsax.tag, size: kIconSize),
        label: Text(
          e,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: kIconSize),
        ),
      ),
    );

    final sharedVaults = item.sharedVaultIds.map(
      (e) {
        final results = SharedVaultsController.to.data.where(
          (x) => x.docId == e,
        );

        SharedVault? vault;
        if (results.isNotEmpty) vault = results.first;
        Widget icon = const Icon(Iconsax.share, size: kIconSize);

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
            style: const TextStyle(fontSize: kIconSize),
          ),
        );
      },
    );

    final bottomSubTitle = Wrap(
      runSpacing: 5,
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (item.favorite) ...[
          const Icon(Iconsax.heart, color: Colors.pink, size: kIconSize),
        ],
        if (item.protected) ...[
          Icon(Iconsax.shield_tick, color: themeColor, size: kIconSize),
        ],
        if (item.attachments.isNotEmpty) ...[
          const Icon(Iconsax.attach_circle, size: kIconSize),
        ],
        if (item.reserved) ...[
          const Icon(Iconsax.key, color: Colors.lightBlue, size: kIconSize),
        ],
        ...tags,
        ...sharedVaults,
        Text(
          item.updatedTimeAgo,
          style: const TextStyle(fontSize: kIconSize, color: Colors.grey),
        ),
        if (item.trashed) ...[
          Text(
            '${item.daysLeftToDelete} days left till ',
            style: const TextStyle(fontSize: kIconSize, color: Colors.red),
          ),
          const Icon(Iconsax.trash, color: Colors.red, size: kIconSize),
        ],
      ],
    );

    final leading = item.iconUrl.isNotEmpty
        ? RemoteImage(
            url: item.iconUrl,
            width: 35,
            alignment: Alignment.centerLeft,
          )
        : AppUtils.categoryIcon(item.category, color: themeColor);

    var tile = ListTile(
      selected: item.deleted,
      selectedColor: item.deleted ? Colors.red : null,
      leading: leading,
      // for some reason, using subtitle gets a lot of errors so we're not using it
      // subtitle: subTitle,
      // contentPadding: const EdgeInsets.only(left: 16, right: 6),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title.isNotEmpty ? item.title : '(Untitled)',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (item.subTitle.trim().isNotEmpty) ...[
            Text(
              item.subTitle.isNotEmpty ? item.subTitle : '(Untitled)',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 13),
            ),
          ],
          const SizedBox(height: 3),
          bottomSubTitle,
        ],
      ),
      trailing: isAutofill
          ? null
          : ContextMenuButton(
              menuItems,
              child: const Icon(LineIcons.verticalEllipsis),
            ),
      onLongPress: isLargeScreen || isAutofill
          ? null
          : () => ContextMenuSheet(menuItems).show(),
      onTap: _open,
    );

    if (isLargeScreen || isAutofill) return tile;

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
          icon: const Icon(Iconsax.refresh, color: Colors.white),
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
