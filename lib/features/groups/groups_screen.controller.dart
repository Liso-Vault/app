import 'package:app_core/globals.dart';
import 'package:app_core/purchases/purchases.services.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/hive/models/group.hive.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/globals.dart';
import 'groups.controller.dart';
import 'groups.service.dart';

class GroupsScreenController extends GetxController with ConsoleMixin {
  static GroupsScreenController get to => Get.find();

  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  HiveLisoGroup? object;
  bool createMode = true;

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void edit(HiveLisoGroup object_) async {
    createMode = false;
    object = object_;
    nameController.text = object!.name;
    descriptionController.text = object!.description;
    showForm();
  }

  void create() async {
    createMode = true;
    object = null;
    nameController.clear();
    descriptionController.clear();
    showForm();
  }

  void showForm() async {
    void done() {
      AppPersistence.to.changes.val++;
      GroupsController.to.load();
      // clear fields
      nameController.clear();
      descriptionController.clear();

      NotificationsService.to.notify(
        title: 'Custom Vault ${createMode ? 'Created' : 'Updated'}',
        body: nameController.text,
      );

      Get.backLegacy();
    }

    void create() async {
      if (!formKey.currentState!.validate()) return;

      final exists = GroupsController.to.combined
          .where((e) => e.name == nameController.text)
          .isNotEmpty;

      if (exists) {
        Get.backLegacy();

        return UIUtils.showSimpleDialog(
          'Custom Vault Already Exists',
          '"${nameController.text}" already exists.',
        );
      }

      if (GroupsController.to.data.length >= limits.customVaults) {
        PurchasesService.to.show();
        return;
      }

      await GroupsService.to.box!.add(HiveLisoGroup(
        id: const Uuid().v4(),
        name: nameController.text,
        description: descriptionController.text,
        metadata: await HiveMetadata.get(),
      ));

      done();
    }

    void edit() async {
      if (!formKey.currentState!.validate()) return;
      object!.name = nameController.text;
      object!.description = descriptionController.text;
      object!.metadata = await HiveMetadata.get();
      object!.save();
      done();
    }

    final content = Form(
      key: formKey,
      child: Column(
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
              hintText: 'Vault Name',
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
          ),
        ],
      ),
    );

    Get.dialog(AlertDialog(
      title: Text('${createMode ? 'new' : 'update'}_custom_vault'.tr),
      content: isSmallScreen ? content : SizedBox(width: 450, child: content),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: createMode ? create : edit,
          child: Text(createMode ? 'create' : 'update'.tr),
        ),
      ],
    ));
  }
}
