import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/categories/categories.controller.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/joined_vaults/joined_vault.controller.dart';
import 'package:liso/features/joined_vaults/model/member.model.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/firebase/crashlytics.service.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';

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
  @override
  void onReady() {
    // Fix stuck loading bug
    Future.delayed(1.seconds).then((value) {
      if (JoinedVaultsController.to.busy.value) {
        JoinedVaultsController.to.restart();
      }
    });

    super.onReady();
  }

  void _join() async {
    if (!formKey.currentState!.validate()) return;
    Get.back(); // close dialog

    // check if already a member of the vault
    final alreadyJoined = JoinedVaultsController.to.data
        .where((e) => e.docId == vaultIdController.text);

    if (alreadyJoined.isNotEmpty) {
      return UIUtils.showSimpleDialog(
        'Already Joined This Vault',
        'You are already a member of this vault',
      );
    }

    final sharedVaultDoc = FirestoreService.to.sharedVaults.doc(
      vaultIdController.text,
    );

    final membersCol = sharedVaultDoc.collection(kVaultMembersCollection);

    final statsSnapshot = await membersCol.doc(kStatsDoc).get();
    final existingMembers = statsSnapshot.data()?['count'] ?? 0;
    console.info('existingMembers: $existingMembers');

    final sharedVaultSnapshot = await sharedVaultDoc.get();
    final sharedVault = sharedVaultSnapshot.data();

    if (sharedVault == null) {
      return UIUtils.showSimpleDialog(
        'Shared Vault Not Found',
        'The shared vault with ID: ${vaultIdController.text} does not exist.',
      );
    }

    final ownerDoc = FirestoreService.to.users.doc(sharedVault.userId);
    final ownerSnapshot = await ownerDoc.get();
    final owner = ownerSnapshot.data()!;

    // obtain owner limits
    var ownerLimits = ConfigService.to.limits.free;

    if (owner.limits == 'holder') {
      ownerLimits = ConfigService.to.limits.holder;
    } else if (owner.limits == 'staker') {
      ownerLimits = ConfigService.to.limits.staker;
    } else if (owner.limits == 'pro') {
      ownerLimits = ConfigService.to.limits.pro;
    }

    if (existingMembers >= ownerLimits.sharedMembers) {
      return UIUtils.showSimpleDialog(
        'Unable To Join',
        'The owner of the shared vault reached the max members limit',
      );
    }

    // obtain vault object
    final snapshot = await FirestoreService.to.sharedVaults
        .where(FieldPath.documentId, isEqualTo: vaultIdController.text)
        .get();

    if (snapshot.docs.isEmpty) {
      return UIUtils.showSimpleDialog(
        'Shared Vault Not Found',
        'The shared vault with ID: ${vaultIdController.text} cannot be found',
      );
    }

    final vault = snapshot.docs.first.data();
    console.info('${vault.name} -> ${vault.description}');

    // check if we're joining our own vault
    if (vault.userId == AuthService.to.userId) {
      return UIUtils.showSimpleDialog(
        'Cannot Join Own Vault',
        "It's not allowed to join your own vault",
      );
    }

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

    // add self as a member of the shared vault
    // TODO: allow user to set permissions using Choice Chips UI
    final member = VaultMember(
      address: WalletService.to.longAddress,
      userId: AuthService.to.userId,
      permissions: ['update', 'delete'].join(','),
    );

    final memberDoc = membersCol
        .withConverter<VaultMember>(
          fromFirestore: (snapshot, _) => VaultMember.fromSnapshot(snapshot),
          toFirestore: (object, _) => object.toJson(),
        )
        .doc();

    final batch = FirestoreService.to.instance.batch();
    // remove from firestore
    batch.set(memberDoc, member);

    batch.set(
      membersCol.doc(kStatsDoc),
      {
        'count': FieldValue.increment(1),
        'updatedTime': FieldValue.serverTimestamp(),
        'userId': AuthService.to.userId,
      },
      SetOptions(merge: true),
    );

    try {
      await batch.commit();
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);

      return UIUtils.showSimpleDialog(
        'Failed To Join',
        'Error joining in server',
      );
    }

    console.wtf('member added: ${memberDoc.id}');

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
            'This is the key to decrypt the shared vault. Please keep it as it is.';
        return e;
      } else {
        return e;
      }
    }).toList();

    // save cipher key as a liso item
    await ItemsService.to.box!.add(HiveLisoItem(
      identifier: vault.docId,
      groupId: 'secrets', // TODO: use enums for reserved groups
      category: category.id,
      title: '${vault.name} Shared Vault Cipher Key',
      fields: fields,
      metadata: await HiveMetadata.get(),
      protected: true,
      reserved: true,
      tags: ['secret'],
    ));

    // reload main screen
    ItemsController.to.load();
    console.wtf('created liso item');
    vaultIdController.clear();
    cipherKeyController.clear();

    // send notification
    NotificationsManager.notify(
      title: 'Shared Vault Joined',
      body: vault.name,
    );
  }

  void joinDialog() async {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: vaultIdController,
          autofocus: true,
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
