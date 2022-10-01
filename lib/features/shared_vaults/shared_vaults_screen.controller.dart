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
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/files/storage.service.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/shared_vaults/model/shared_vault.model.dart';
import 'package:liso/features/shared_vaults/shared_vault.controller.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/firebase/crashlytics.service.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../categories/categories.controller.dart';
import '../pro/pro.controller.dart';

class SharedVaultsScreenController extends GetxController with ConsoleMixin {
  static SharedVaultsScreenController get to => Get.find();

  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final cipherKeyController = TextEditingController();

  SharedVault? object;
  bool createMode = true;

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

  void edit(SharedVault object_) async {
    createMode = false;
    object = object_;
    nameController.text = object!.name;
    descriptionController.text = object!.description;
    console.wtf('doc: ${object_.docId}');
    _showForm();
  }

  void create() async {
    createMode = true;
    object = null;
    nameController.clear();
    descriptionController.clear();
    cipherKeyController.clear();
    _showForm();
  }

  void _showForm() async {
    void done() {
      // clear fields
      nameController.clear();
      descriptionController.clear();
      cipherKeyController.clear();

      NotificationsManager.notify(
        title: 'Shared Vault ${createMode ? 'Created' : 'Updated'}',
        body: nameController.text,
      );

      Get.back();
    }

    void edit() async {
      if (!formKey.currentState!.validate()) return;
      final doc = FirestoreService.to.vaultsCol.doc(object?.docId);

      await doc.set(
        {
          'name': nameController.text,
          'description': descriptionController.text,
          'updatedTime': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      done();
    }

    void create() async {
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

      if (SharedVaultsController.to.data.length >=
          ProController.to.limits.sharedVaults) {
        return Utils.adaptiveRouteOpen(
          name: Routes.upgrade,
          parameters: {
            'title': 'Shared Vaults',
            'body':
                'Maximum members: ${ProController.to.limits.sharedMembers} in shared vault reached. Upgrade to Pro to unlock unlimited shared vault members feature.',
          },
        );
      }

      // add to firestore
      final vault = SharedVault(
        userId: AuthService.to.userId,
        address: SecretPersistence.to.longAddress,
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
      await ItemsService.to.box!.add(HiveLisoItem(
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

      // reload items
      ItemsController.to.load();
      console.wtf('created liso item');

      done();
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
        if (createMode) ...[
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
                  'The Cipher Key will be automatically be saved as a ${ConfigService.to.appName} Item',
              suffixIcon: IconButton(
                icon: const Icon(Iconsax.key),
                onPressed: () {
                  cipherKeyController.text = base64Encode(
                    Hive.generateSecureKey(),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );

    Get.dialog(AlertDialog(
      title: Text('${createMode ? 'New' : 'Update'} Shared Vault'),
      content: Form(
        key: formKey,
        child: Utils.isSmallScreen
            ? content
            : SizedBox(width: 450, child: content),
      ),
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

  void delete(SharedVault object_) {
    void confirm() async {
      Get.back();

      final batch = FirestoreService.to.instance.batch();
      final doc = FirestoreService.to.sharedVaults.doc(object_.docId);
      // update user doc
      batch.delete(doc);
      // update users collection stats counter
      batch.set(
        FirestoreService.to.vaultsStatsDoc,
        {
          'count': FieldValue.increment(-1),
          'updatedTime': FieldValue.serverTimestamp(),
          'userId': AuthService.to.userId
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

      final object = 'Shared/${object_.docId}.$kVaultExtension';
      await StorageService.to.remove(object);

      console.info('deleted: ${doc.id}');
    }

    final dialogContent = Text(
      'Are you sure you want to delete "${object_.name}"?',
    );

    Get.dialog(AlertDialog(
      title: Text('Delete ${object_.name}'),
      content: Utils.isSmallScreen
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
          onPressed: confirm,
          child: Text('confirm_delete'.tr),
        ),
      ],
    ));
  }
}
