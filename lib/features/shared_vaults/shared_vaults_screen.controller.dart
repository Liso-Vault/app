import 'dart:convert';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/hive/hive_items.service.dart';
import 'package:liso/core/hive/hive_shared_vaults.service.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:liso/core/hive/models/shared_vault.hive.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/shared_vaults/model/shared_vault.model.dart';
import 'package:liso/features/shared_vaults/shared_vault.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/parsers/template.parser.dart';
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
    final cipherKeyController = TextEditingController();

    void _create() async {
      if (!formKey.currentState!.validate()) return;

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
      console.wtf('created shared vault: ${doc.id}');

      final result = await S3Service.to.createBlankFile(join(
        S3Service.to.sharedPath,
        '${doc.id}.$kVaultExtension',
      ));

      if (result.isLeft) {
        // abort creation
        await doc.delete();

        return UIUtils.showSimpleDialog(
          'Failed Creating Shared Vault',
          '${result.left}',
        );
      }

      await doc.update({'eTag': result.right});
      console.info('updated with eTag: ${result.right}');

      const category = LisoItemCategory.encryption;
      var fields = TemplateParser.parse(category.name);

      // inject cipher key to fields
      fields = fields.map((e) {
        if (e.identifier == 'key') {
          e.data.value = cipherKeyController.text;
          return e;
        } else {
          return e;
        }
      }).toList();

      // save cipher key as a liso item
      await HiveItemsService.to.box.add(HiveLisoItem(
        identifier: const Uuid().v4(),
        groupId: 'personal',
        category: category.name,
        title: '${nameController.text} Shared Vault Cipher Key',
        fields: fields,
        metadata: await HiveMetadata.get(),
        protected: true,
        tags: ['cipher'],
      ));

      // save cipher key
      await HiveSharedVaultsService.to.box.add(HiveSharedVault(
        id: doc.id,
        cipherKey: base64Decode(cipherKeyController.text),
      ));

      NotificationsManager.notify(
        title: 'Shared Vault Created',
        body: nameController.text,
      );

      MainScreenController.to.load();
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
                cipherKeyController.text =
                    base64Encode(Hive.generateSecureKey());
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
