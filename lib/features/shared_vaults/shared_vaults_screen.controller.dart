import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/features/shared_vaults/model/shared_vault.model.dart';
import 'package:liso/features/shared_vaults/shared_vault.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';

class SharedVaultsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SharedVaultsScreenController(), fenix: true);
  }
}

class SharedVaultsScreenController extends GetxController with ConsoleMixin {
  static SharedVaultsScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void create() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    void _create() async {
      final exists =
          await SharedVaultsController.to.exists(nameController.text);

      if (exists) {
        return UIUtils.showSimpleDialog(
          'Shared Vault Already Exists',
          '"${nameController.text}" already exists.',
        );
      }

      Get.back();

      final vault = SharedVault(
        userId: AuthService.to.user!.uid,
        address: WalletService.to.longAddress,
        name: nameController.text,
        description: descriptionController.text,
      );

      final doc = await FirestoreService.to.vaults.add(vault);
      console.wtf('created doc: ${doc.id}');

      NotificationsManager.notify(
        title: 'Shared Vault Created',
        body: nameController.text,
      );
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 30,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (data) {
            if (data!.isNotEmpty) return null;
            return 'Invalid Name';
          },
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Shared Vault Name',
          ),
        ),
        TextFormField(
          controller: descriptionController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 100,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'optional',
          ),
        )
      ],
    );

    Get.dialog(AlertDialog(
      title: Text('new_vault'.tr),
      content: Form(
        key: formKey,
        child: Utils.isDrawerExpandable
            ? content
            : SizedBox(width: 450, child: content),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: _create,
          child: Text('create'.tr),
        ),
      ],
    ));
  }
}
