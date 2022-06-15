import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/notifications/notifications.manager.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../wallet/wallet.service.dart';
import 'categories.controller.dart';
import 'categories.service.dart';

class CategoriesScreenController extends GetxController with ConsoleMixin {
  static CategoriesScreenController get to => Get.find();

  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  HiveLisoCategory? object;
  HiveLisoCategory? template;
  bool createMode = true;

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void edit(HiveLisoCategory object_) async {
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
      CategoriesController.to.load();

      NotificationsManager.notify(
        title: 'Category ${createMode ? 'Created' : 'Updated'}',
        body: nameController.text,
      );

      Get.back();
    }

    void _create() async {
      if (!formKey.currentState!.validate()) return;

      final exists = CategoriesController.to.combined
          .where((e) => e.name == nameController.text)
          .isNotEmpty;

      if (exists) {
        Get.back();

        return UIUtils.showSimpleDialog(
          'Category Already Exists',
          '"${nameController.text}" already exists.',
        );
      }

      if (CategoriesController.to.data.length >=
          WalletService.to.limits.customCategories) {
        return Utils.adaptiveRouteOpen(
          name: Routes.upgrade,
          parameters: {
            'title': 'Title',
            'body': 'Maximum custom category limit reached',
          }, // TODO: add message
        );
      }

      await CategoriesService.to.box!.add(HiveLisoCategory(
        id: const Uuid().v4(),
        name: nameController.text,
        description: descriptionController.text,
        fields: template!.fields,
        significant: template!.significant,
        metadata: await HiveMetadata.get(),
      ));

      _done();
    }

    void _edit() async {
      if (!formKey.currentState!.validate()) return;
      object!.name = nameController.text;
      object!.description = descriptionController.text;
      object!.fields = template!.fields;
      object!.significant = template!.significant;
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
              hintText: 'Category Name',
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
          DropdownButtonFormField<HiveLisoCategory>(
            isExpanded: true,
            onChanged: (value) => template = value!,
            decoration: const InputDecoration(labelText: 'Template'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (data) {
              if (data != null) return null;
              return 'Required';
            },
            items: CategoriesController.to.combined
                .map((e) => DropdownMenuItem<HiveLisoCategory>(
                      value: e,
                      child: Text(e.reservedName),
                    ))
                .toList(),
          ),
        ],
      ),
    );

    Get.dialog(AlertDialog(
      title: Text('${createMode ? 'new' : 'update'}_category'.tr),
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
