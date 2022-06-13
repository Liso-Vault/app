import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/features/item/items.service.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/shared_vaults/model/shared_vault.model.dart';
import 'package:liso/features/shared_vaults/shared_vault.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/firebase/crashlytics.service.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../categories/categories.controller.dart';

class SharedVaultsScreenController extends GetxController with ConsoleMixin {
  static SharedVaultsScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onReady() {
    // Fix stuck loading bug
    Future.delayed(1.seconds).then((value) {
      if (SharedVaultsController.to.busy.value) {
        SharedVaultsController.to.restart();
      }
    });

    super.onReady();
  }

  // FUNCTIONS

  void create() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final cipherKeyController = TextEditingController();

    void _create() async {
      if (!formKey.currentState!.validate()) return;

      // check if name already exists
      final exists = await SharedVaultsController.to.exists(
        nameController.text,
      );

      if (exists) {
        return UIUtils.showSimpleDialog(
          'Already Exists',
          '"${nameController.text}" already exists.',
        );
      }

      Get.back(); // close dialog

      if (SharedVaultsController.to.data.length >=
          WalletService.to.limits.sharedVaults) {
        return Utils.adaptiveRouteOpen(
          name: Routes.upgrade,
          parameters: {
            'title': 'Title',
            'body': 'Maximum members in shared vault reached',
          }, // TODO: add message
        );
      }

      // add to firestore
      final vault = SharedVault(
        userId: AuthService.to.userId,
        address: WalletService.to.longAddress,
        name: nameController.text,
        description: descriptionController.text,
      );

      final batch = FirestoreService.to.instance.batch();
      final doc = FirestoreService.to.sharedVaults.doc();

      // update user doc
      batch.set(
        doc,
        vault,
        SetOptions(merge: true),
      );

      // update users collection stats counter
      batch.set(
        FirestoreService.to.vaultsStatsDoc,
        {
          'count': FieldValue.increment(1),
          'updatedTime': FieldValue.serverTimestamp(),
          'userId': AuthService.to.userId,
        },
        SetOptions(merge: true),
      );

      // commit batch
      try {
        await batch.commit();
      } catch (e, s) {
        CrashlyticsService.to.record(e, s);
        return console.error("error batch commit: $e");
      }

      console.wtf('created shared vault: ${doc.id}');

      // inject cipher key to fields
      final category = CategoriesController.to.combined
          .firstWhere((e) => e.id == LisoItemCategory.encryption.name);
      var fields = category.fields;

      fields = fields.map((e) {
        if (e.identifier == 'key') {
          e.data.value = cipherKeyController.text;
          e.readOnly = true;
          return e;
        } else if (e.identifier == 'note') {
          e.data.value =
              'Please share this safely to those you want to access the shared vault. It is recommended you keep this item.';
          return e;
        } else {
          return e;
        }
      }).toList();

      // save cipher key as a liso item
      await ItemsService.to.box.add(HiveLisoItem(
        identifier: doc.id,
        groupId: 'secrets', // TODO: use enums for reserved groups
        category: category.id,
        title: '${nameController.text} Shared Vault Cipher Key',
        fields: fields,
        metadata: await HiveMetadata.get(),
        protected: true,
        reserved: true,
        tags: ['secret'],
      ));

      console.wtf('created liso item');

      // send notification
      NotificationsManager.notify(
        title: 'Shared Vault Created',
        body: nameController.text,
      );

      // reload main screen
      MainScreenController.to.load();
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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
        ),
        TextFormField(
          controller: cipherKeyController,
          autofocus: true,
          maxLength: 44,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (data) {
            const errorString =
                'Cipher Key must be base64 encoded and 32 bits in length';

            late Uint8List decoded;

            try {
              decoded = base64Decode(data!);
            } catch (e) {
              return errorString;
            }

            if (decoded.length == 32) return null;
            return errorString;
          },
          decoration: InputDecoration(
            labelText: 'Cipher Key',
            hintText: '32 Bit Base64 Cipher Key',
            helperText:
                'Cipher Key will be automatically be saved as a ${ConfigService.to.appName} Item',
            suffixIcon: IconButton(
              onPressed: () {
                cipherKeyController.text = base64Encode(
                  Hive.generateSecureKey(),
                );
              },
              icon: const Icon(Iconsax.key),
            ),
          ),
        )
      ],
    );

    Get.dialog(AlertDialog(
      title: Text('new_shared_vault'.tr),
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
