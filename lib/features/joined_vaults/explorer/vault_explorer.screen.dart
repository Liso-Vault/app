import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../general/appbar_leading.widget.dart';
import '../../general/busy_indicator.widget.dart';
import '../../general/centered_placeholder.widget.dart';
import '../../item/item.tile.dart';
import 'vault_explorer_screen.controller.dart';

class VaultExplorerScreen extends GetView<VaultExplorerScreenController>
    with ConsoleMixin {
  const VaultExplorerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vault = VaultExplorerScreenController.vault;

    Widget itemBuilder(context, index) {
      return ItemTile(
        controller.data[index],
        key: GlobalKey(), // TODO: do we still need this?
        joinedVaultItem: true,
      );
    }

    final listView = Obx(
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        separatorBuilder: (_, index) => const Divider(height: 0),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 15),
      ),
    );

    final content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onError: (message) => CenteredPlaceholder(
        iconData: Iconsax.warning_2,
        message: message!,
      ),
      onEmpty: Obx(
        () => CenteredPlaceholder(
          iconData: Iconsax.document,
          message: 'no_items'.tr,
        ),
      ),
    );

    final appBar = AppBar(
      title: Text('${vault.name} Shared Vault'),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        Obx(
          () => IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: !controller.busy.value ? controller.search : null,
          ),
        ),
        // Obx(
        //   () => ContextMenuButton(
        //     controller.menuItemsSort,
        //     enabled: controller.data.isNotEmpty && !controller.busy,
        //     initialItem: controller.menuItemsSort.firstWhere(
        //       (e) => controller.sortOrder.value.name
        //           .toLowerCase()
        //           .contains(e.title.toLowerCase().replaceAll(' ', '')),
        //     ),
        //     child: IconButton(
        //       icon: const Icon(Iconsax.sort),
        //       onPressed:
        //           controller.data.isNotEmpty && !controller.busy ? () {} : null,
        //     ),
        //   ),
        // ),
        const SizedBox(width: 10),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
