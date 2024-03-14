import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:skeletons/skeletons.dart';

import '../../general/centered_placeholder.widget.dart';
import '../../items/item.tile.dart';
import '../../menu/menu.button.dart';
import 'vault_explorer_screen.controller.dart';

class VaultExplorerScreen extends StatelessWidget with ConsoleMixin {
  const VaultExplorerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaultExplorerScreenController());
    final vault = VaultExplorerScreenController.vault;

    Widget itemBuilder(context, index) {
      return ItemTile(
        controller.data[index],
        joinedVaultItem: true,
      );
    }

    final skeleton = SkeletonListView(
      item: SkeletonListTile(
        verticalSpacing: 12,
        leadingStyle: const SkeletonAvatarStyle(
          width: 40,
          height: 40,
          shape: BoxShape.circle,
        ),
        titleStyle: SkeletonLineStyle(
          height: 16,
          minLength: 200,
          randomLength: true,
          borderRadius: BorderRadius.circular(12),
        ),
        subtitleStyle: SkeletonLineStyle(
          height: 12,
          maxLength: 200,
          randomLength: true,
          borderRadius: BorderRadius.circular(12),
        ),
        hasSubtitle: true,
      ),
    );

    final listView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 15),
      ),
    );

    final content = controller.obx(
      (_) => listView,
      onLoading: skeleton,
      onError: (message) => CenteredPlaceholder(
        iconData: Iconsax.warning_2_outline,
        message: message!,
      ),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.document_outline,
        message: 'no_items'.tr,
      ),
    );

    final button = IconButton(
      icon: const Icon(Iconsax.refresh_outline),
      onPressed: controller.init,
    );

    const progressIndicator = Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(),
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
            icon: const Icon(Iconsax.search_normal_outline),
            onPressed: !controller.busy.value ? controller.search : null,
          ),
        ),
        Obx(
          () => ContextMenuButton(
            controller.menuItemsSort,
            enabled: !controller.busy.value,
            initialItem: controller.menuItemsSort.firstWhere(
              (e) => controller.sortOrder.value.name
                  .toLowerCase()
                  .contains(e.title.toLowerCase().replaceAll(' ', '')),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.sort_outline),
              onPressed: !controller.busy.value ? () {} : null,
            ),
          ),
        ),
        Obx(
          () => Visibility(
            visible: controller.busy.value,
            replacement: button,
            child: progressIndicator,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
