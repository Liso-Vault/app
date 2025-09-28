import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../app/routes.dart';
import '../general/centered_placeholder.widget.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'explorer/vault_explorer_screen.controller.dart';
import 'joined_vault.controller.dart';
import 'joined_vaults_screen.controller.dart';

class JoinedVaultsScreen extends StatelessWidget with ConsoleMixin {
  const JoinedVaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JoinedVaultsScreenController());
    final joinedController = Get.find<JoinedVaultsController>();

    Widget itemBuilder(context, index) {
      final vault = joinedController.data[index];

      void open() async {
        VaultExplorerScreenController.vault = vault;
        Utils.adaptiveRouteOpen(name: AppRoutes.vaultExplorer);
      }

      void confirmLeave() {
        void leave() async {
          // TODO: temporary
          // // TODO: delete self as member

          // final membersCol = FirestoreService.to.sharedVaults
          //     .doc(vault.docId)
          //     .collection(kVaultMembersCollection);

          // final snapshot = await membersCol
          //     .where('userId', isEqualTo: AuthService.to.userId)
          //     .get();

          // if (snapshot.docs.isEmpty) {
          //   return UIUtils.showSimpleDialog(
          //     'Failed To Leave',
          //     'Did not find yourself as a member in this vault',
          //   );
          // }

          // final batch = FirestoreService.to.instance.batch();
          // // remove from firestore
          // batch.delete(snapshot.docs.first.reference);

          // batch.set(
          //   membersCol.doc(kStatsDoc),
          //   {
          //     'count': FieldValue.increment(-1),
          //     'updatedTime': FieldValue.serverTimestamp(),
          //     'userId': AuthService.to.userId,
          //   },
          //   SetOptions(merge: true),
          // );

          // try {
          //   await batch.commit();
          // } catch (e, s) {
          //   CrashlyticsService.to.record(e, s);

          //   return UIUtils.showSimpleDialog(
          //     'Failed To Leave',
          //     'Error leaving in server',
          //   );
          // }

          // // remove from items
          // final items = ItemsService.to.data.where(
          //   (e) => e.identifier == vault.docId,
          // );

          // if (items.isNotEmpty) {
          //   await ItemsService.to.box!.deleteAll(items.map((e) => e.key));
          //   console.wtf('permanently deleted');
          // }

          // // close dialog
          // Get.backLegacy();
        }

        final dialogContent = Text(
          'Are you sure you want to leave the shared vault "${vault.name}"?',
        );

        Get.dialog(AlertDialog(
          title: const Text('Leave Shared Vault'),
          content: isSmallScreen
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
              onPressed: leave,
              child: Text('leave'.tr),
            ),
          ],
        ));
      }

      final menuItems = [
        ContextMenuItem(
          title: 'leave'.tr,
          leading: Icon(Iconsax.logout_outline, size: popupIconSize),
          onSelected: confirmLeave,
        ),
      ];

      return ListTile(
        onTap: open,
        title: Text(vault.name),
        subtitle: vault.description.isNotEmpty ? Text(vault.description) : null,
        leading: vault.iconUrl.isEmpty
            ? const Icon(Iconsax.briefcase_outline)
            : RemoteImage(
                url: vault.iconUrl,
                width: 35,
                alignment: Alignment.centerLeft,
              ),
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineAwesome.ellipsis_v_solid),
        ),
      );
    }

    final listView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: joinedController.data.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );

    final content = joinedController.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.briefcase_outline,
        message: 'no_joined_vaults'.tr,
      ),
      onError: (message) => CenteredPlaceholder(
        iconData: Iconsax.warning_2_outline,
        message: message!,
        child: TextButton(
          onPressed: joinedController.restart,
          child: Text('try_again'.tr),
        ),
      ),
    );

    final appBar = AppBar(
      title: Obx(
        () => Text('${joinedController.data.length} ${'joined_vaults'.tr}'),
      ),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: const Text('Need Help ?'),
        ),
      ],
    );

    final floatingActionButton = FloatingActionButton(
      onPressed: controller.joinDialog,
      child: const Icon(LineAwesome.plus_solid),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
