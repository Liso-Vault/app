import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/hive/models/group.hive.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../wallet/wallet.service.dart';
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
    _showForm();
  }

  void create() async {
    createMode = true;
    object = null;
    nameController.clear();
    descriptionController.clear();
    _showForm();
  }

  void _showForm() async {
    void _done() {
      Persistence.to.changes.val++;
      GroupsController.to.load();

      NotificationsManager.notify(
        title: 'Custom Vault ${createMode ? 'Created' : 'Updated'}',
        body: nameController.text,
      );

      Get.back();
    }

    void _create() async {
      if (!formKey.currentState!.validate()) return;

      final exists = GroupsController.to.combined
          .where((e) => e.name == nameController.text)
          .isNotEmpty;

      if (exists) {
        Get.back();

        return UIUtils.showSimpleDialog(
          'Custom Vault Already Exists',
          '"${nameController.text}" already exists.',
        );
      }

      if (GroupsController.to.data.length >=
          WalletService.to.limits.customVaults) {
        return Utils.adaptiveRouteOpen(
          name: Routes.upgrade,
          parameters: {
            'title': 'Title',
            'body': 'Maximum custom vault limit reached',
          }, // TODO: add message
        );
      }

      await GroupsService.to.box!.add(HiveLisoGroup(
        id: const Uuid().v4(),
        name: nameController.text,
        description: descriptionController.text,
        metadata: await HiveMetadata.get(),
      ));

      _done();
    }

    void _edit() async {
      if (!formKey.currentState!.validate()) return;
      object!.name = nameController.text;
      object!.description = descriptionController.text;
      object!.metadata = await HiveMetadata.get();
      object!.save();
      _done();
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
      content: Utils.isDrawerExpandable
          ? content
          : SizedBox(width: 450, child: content),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: createMode ? _create : _edit,
          child: Text(createMode ? 'create' : 'update'.tr),
        ),
      ],
    ));
  }
}
