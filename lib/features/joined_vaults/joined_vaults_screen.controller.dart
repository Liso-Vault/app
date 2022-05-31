import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/hive/hive_items.service.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/joined_vaults/model/member.model.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/parsers/template.parser.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';

class JoinedVaultsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JoinedVaultsScreenController(), fenix: true);
  }
}

class JoinedVaultsScreenController extends GetxController with ConsoleMixin {
  static JoinedVaultsScreenController get to => Get.find();

  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final vaultIdController = TextEditingController();
  final cipherKeyController = TextEditingController();

  // PROPERTIES

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void _join() async {
    if (!formKey.currentState!.validate()) return;
    Get.back(); // close dialog

    final snapshot = await FirestoreService.to.sharedVaults
        .where(
          FieldPath.documentId,
          isEqualTo: vaultIdController.text,
        )
        .get();

    if (snapshot.docs.isEmpty) {
      return UIUtils.showSimpleDialog(
        'Shared Vault Not Found',
        'The shared vault with ID: ${vaultIdController.text} cannot be found',
      );
    }

    final vault = snapshot.docs.first.data();
    console.info('${vault.name} -> ${vault.description}');

    // download vault file
    final s3Path = '${vault.address}/Shared/${vault.docId}.$kVaultExtension';

    final result = await S3Service.to.downloadFile(
      s3Path: s3Path,
      filePath: LisoPaths.tempVaultFilePath,
    );

    if (result.isLeft) {
      return UIUtils.showSimpleDialog(
        'Shared Vault File Not Found',
        'The shared vault file with ID: ${vaultIdController.text} cannot be found',
      );
    }

    // decrypt vault
    final cipherKey = base64Decode(cipherKeyController.text);

    final correctCipherKey = await CipherService.to.canDecrypt(
      result.right,
      cipherKey,
    );

    if (!correctCipherKey) {
      return UIUtils.showSimpleDialog(
        'Failed To Decrypt',
        'The cipher key you entered failed to decrypt the shared vault.',
      );
    }

    final decryptedFile = await CipherService.to.decryptFile(
      result.right,
      cipherKey: cipherKey,
    );

    // import vault items
    console.wtf('we are in!');

    // I1apLmilUtBoGMztYKbdx47k8P9ZMollzB3nJTCnwxU=

    // TODO: extract vault and check if cipher key is correct

    // add self as a member of the shared vault
    // TODO: allow user to set permissions
    final member = VaultMember(
      address: WalletService.to.longAddress,
      userId: AuthService.to.userId,
      permissions: ['update', 'delete'].join(','),
    );

    final memberDoc = await snapshot.docs.first.reference
        .collection('members')
        .withConverter<VaultMember>(
          fromFirestore: (snapshot, _) => VaultMember.fromSnapshot(snapshot),
          toFirestore: (object, _) => object.toJson(),
        )
        .add(member);

    console.wtf('member added: ${memberDoc.id}');

    // inject cipher key to fields
    const category = LisoItemCategory.encryption;
    var fields = TemplateParser.parse(category.name);

    fields = fields.map((e) {
      if (e.identifier == 'key') {
        e.data.value = cipherKeyController.text;
        e.readOnly = true;
        return e;
      } else if (e.identifier == 'note') {
        e.data.value =
            'This is the key to decrypt the shared vault. Please keep it as it is.';
        return e;
      } else {
        return e;
      }
    }).toList();

    // save cipher key as a liso item
    await HiveItemsService.to.box.add(HiveLisoItem(
      identifier: vault.docId,
      groupId: 'secrets', // TODO: use enums for reserved groups
      category: category.name,
      title: '${vault.name} Shared Vault Cipher Key',
      fields: fields,
      metadata: await HiveMetadata.get(),
      protected: true,
      reserved: true,
      tags: ['secret'],
    ));

    console.wtf('created liso item');

    // send notification
    NotificationsManager.notify(
      title: 'Shared Vault Joined',
      body: vault.name,
    );

    // reload main screen
    MainScreenController.to.load();
  }

  void joinDialog() async {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: vaultIdController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 30,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (data) {
            if (data!.isNotEmpty) return null;
            return 'Invalid Vault ID';
          },
          decoration: const InputDecoration(
            labelText: 'Shared Vault ID',
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
            hintText: 'Enter the provided 32 Bit Base64 Cipher Key',
            helperText:
                'Cipher Key will be automatically be saved as a ${ConfigService.to.appName} Item',
          ),
        )
      ],
    );

    Get.dialog(AlertDialog(
      title: Text('join_shared_vault'.tr),
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
          onPressed: _join,
          child: Text('join'.tr),
        ),
      ],
    ));
  }
}