import 'package:app_core/globals.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/persistence/persistence.dart';
import '../../core/utils/globals.dart';
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
    void done() {
      AppPersistence.to.changes.val++;
      CategoriesController.to.load();
      // clear fields
      nameController.clear();
      descriptionController.clear();

      NotificationsService.to.notify(
        title: 'Category ${createMode ? 'Created' : 'Updated'}',
        body: nameController.text,
      );

      Get.backLegacy();
    }

    void create() async {
      if (!formKey.currentState!.validate()) return;

      final exists = CategoriesController.to.combined
          .where((e) => e.name == nameController.text)
          .isNotEmpty;

      if (exists) {
        Get.backLegacy();

        return UIUtils.showSimpleDialog(
          'Category Already Exists',
          '"${nameController.text}" already exists.',
        );
      }

      if (CategoriesController.to.data.length >= limits.customCategories) {
        return Utils.adaptiveRouteOpen(
          name: Routes.upgrade,
          parameters: {
            'title': 'Custom Categories',
            'body':
                'Maximum custom categories of ${limits.customCategories} limit reached. Upgrade to Pro to unlock unlimited custom categories feature.',
          },
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

      done();
    }

    void edit() async {
      if (!formKey.currentState!.validate()) return;
      object!.name = nameController.text;
      object!.description = descriptionController.text;
      object!.fields = template!.fields;
      object!.significant = template!.significant;
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
      content: isSmallScreen ? content : SizedBox(width: 450, child: content),
      actions: [
        TextButton(
          onPressed: Get.close,
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
