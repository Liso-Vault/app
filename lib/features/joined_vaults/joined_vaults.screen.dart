import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/hive/hive_items.service.dart';
import 'package:liso/core/utils/ui_utils.dart';

import '../../core/firebase/crashlytics.service.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import '../general/centered_placeholder.widget.dart';
import '../general/remote_image.widget.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'explorer/vault_explorer_screen.controller.dart';
import 'joined_vault.controller.dart';
import 'joined_vaults_screen.controller.dart';

class JoinedVaultsScreen extends GetView<JoinedVaultsScreenController>
    with ConsoleMixin {
  const JoinedVaultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final joinedController = Get.find<JoinedVaultsController>();

    Widget itemBuilder(context, index) {
      final vault = joinedController.data[index];

      void _confirmLeave() {
        void _leave() async {
          // TODO: delete self as member

          final membersCol = FirestoreService.to.sharedVaults
              .doc(vault.docId)
              .collection(kVaultMembersCollection);

          final snapshot = await membersCol
              .where('userId', isEqualTo: AuthService.to.userId)
              .get();

          if (snapshot.docs.isEmpty) {
            return UIUtils.showSimpleDialog(
              'Failed To Leave',
              'Did not find yourself as a member in this vault',
            );
          }

          final batch = FirestoreService.to.instance.batch();
          // remove from firestore
          batch.delete(snapshot.docs.first.reference);

          batch.set(
            membersCol.doc(kStatsDoc),
            {
              'count': FieldValue.increment(-1),
              'updatedTime': FieldValue.serverTimestamp(),
              'userId': AuthService.to.userId,
            },
            SetOptions(merge: true),
          );

          try {
            await batch.commit();
          } catch (e, s) {
            CrashlyticsService.to.record(e, s);

            return UIUtils.showSimpleDialog(
              'Failed To Leave',
              'Error leaving in server',
            );
          }

          // remove from items
          final items = HiveItemsService.to.data.where(
            (e) => e.identifier == vault.docId,
          );

          if (items.isNotEmpty) {
            await HiveItemsService.to.box.deleteAll(items.map((e) => e.key));
            console.wtf('permanently deleted');
          }

          // close dialog
          Get.back();
        }

        final dialogContent = Text(
          'Are you sure you want to leave the shared vault "${vault.name}"?',
        );

        Get.dialog(AlertDialog(
          title: const Text('Leave Shared Vault'),
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
              onPressed: _leave,
              child: Text('leave'.tr),
            ),
          ],
        ));
      }

      final menuItems = [
        ContextMenuItem(
          title: 'leave'.tr,
          leading: const Icon(Iconsax.logout),
          onSelected: _confirmLeave,
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
        onTap: () {
          VaultExplorerScreenController.vault = vault;
          Utils.adaptiveRouteOpen(name: Routes.vaultExplorer);
        },
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
        iconData: Iconsax.briefcase,
        message: 'no_joined_vaults'.tr,
      ),
      onError: (message) => CenteredPlaceholder(
        iconData: Iconsax.warning_2,
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
    );

    final floatingActionButton = FloatingActionButton(
      onPressed: controller.joinDialog,
      child: const Icon(LineIcons.plus),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
