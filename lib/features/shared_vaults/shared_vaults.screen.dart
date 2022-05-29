import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/firebase/firestore.service.dart';

import '../../core/utils/utils.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import '../general/centered_placeholder.widget.dart';
import '../general/remote_image.widget.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'shared_vault.controller.dart';
import 'shared_vaults_screen.controller.dart';

class SharedVaultsScreen extends GetView<SharedVaultsScreenController>
    with ConsoleMixin {
  const SharedVaultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharedVaultsController = Get.find<SharedVaultsController>();

    Widget itemBuilder(context, index) {
      final vault = sharedVaultsController.data[index].data();

      void _confirmDelete() async {
        void _delete() async {
          Get.back();
          await FirestoreService.to.vaults.doc(vault.docId).delete();
          console.info('deleted');
        }

        final dialogContent = Text(
          'Are you sure you want to delete the shared vault: "${vault.name}"?',
        );

        Get.dialog(AlertDialog(
          title: Text('delete'.tr),
          content: Utils.isDrawerExpandable
              ? dialogContent
              : SizedBox(
                  width: 450,
                  child: dialogContent,
                ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: _delete,
              child: Text('confirm_delete'.tr),
            ),
          ],
        ));
      }

      final menuItems = [
        ContextMenuItem(
          title: 'delete'.tr,
          leading: const Icon(Iconsax.trash),
          onSelected: _confirmDelete,
        ),
      ];

      return ListTile(
        title: Text(vault.name),
        subtitle: vault.description.isNotEmpty ? Text(vault.description) : null,
        leading: vault.iconUrl.isEmpty
            ? const Icon(Iconsax.briefcase)
            : RemoteImage(
                url: vault.iconUrl,
                width: 35,
                alignment: Alignment.centerLeft,
              ),
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
      );
    }

    final listView = Obx(
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: sharedVaultsController.data.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const Divider(height: 0),
      ),
    );

    final content = sharedVaultsController.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.briefcase,
        message: 'no_shared_vaults'.tr,
      ),
      onError: (message) => CenteredPlaceholder(
        iconData: Iconsax.warning_2,
        message: message!,
        child: TextButton(
          onPressed: sharedVaultsController.restart,
          child: Text('try_again'.tr),
        ),
      ),
    );

    final appBar = AppBar(
      title: Text('shared_vaults'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
    );

    final floatingActionButton = FloatingActionButton(
      onPressed: controller.create,
      child: const Icon(LineIcons.plus),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
