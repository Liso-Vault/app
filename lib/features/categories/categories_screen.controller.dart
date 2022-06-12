import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:uuid/uuid.dart';

import '../../core/hive/hive_categories.service.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../wallet/wallet.service.dart';
import 'categories.controller.dart';

class CategoriesScreenController extends GetxController with ConsoleMixin {
  static CategoriesScreenController get to => Get.find();

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
      if (!formKey.currentState!.validate()) return;

      if (CategoriesController.to.data.length >=
          WalletService.to.limits.customCategories) {
        return Utils.adaptiveRouteOpen(
          name: Routes.upgrade,
          parameters: {
            'title': 'Title',
            'body': 'Maximum encrypted files limit reached',
          }, // TODO: add message
        );
      }

      await HiveCategoriesService.to.box!.add(HiveLisoCategory(
        id: const Uuid().v4(),
        name: nameController.text,
        description: descriptionController.text,
        metadata: await HiveMetadata.get(),
      ));

      NotificationsManager.notify(
        title: 'Category Created',
        body: nameController.text,
      );

      CategoriesController.to.load();
      MainScreenController.to.onItemsUpdated();
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
        )
      ],
    );

    Get.dialog(AlertDialog(
      title: Text('new_category'.tr),
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
          child: Text('create'.tr),
          onPressed: () {
            final exists = CategoriesController.to.combined
                .where((e) => e.name == nameController.text)
                .isNotEmpty;

            if (!exists) {
              Get.back();
              _create();
            } else {
              UIUtils.showSimpleDialog(
                'Category Already Exists',
                '"${nameController.text}" already exists.',
              );
            }
          },
        ),
      ],
    ));
  }
}
