import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/hive/hive_groups.service.dart';
import 'package:liso/core/hive/hive_items.service.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/shared_vaults/model/shared_vault.model.dart';
import 'package:path/path.dart';

import '../../features/joined_vaults/model/member.model.dart';
import '../../features/shared_vaults/shared_vault.controller.dart';
import '../../features/wallet/wallet.service.dart';
import '../hive/models/metadata/app.hive.dart';
import '../hive/models/metadata/device.hive.dart';
import 'crashlytics.service.dart';

class FirestoreService extends GetxService with ConsoleMixin {
  static FirestoreService get to => Get.find();

  // VARIABLES
  final vaultsCol = FirebaseFirestore.instance.collection(
    'shared_vaults',
  );

  final vaultMembersCol = FirebaseFirestore.instance.collectionGroup(
    'members',
  );

  final usersCol = FirebaseFirestore.instance.collection(
    'users',
  );

  late CollectionReference<SharedVault> sharedVaults;

  late Query<VaultMember> vaultMembers;

  // PROPERTIES

  // GETTERS
  FirebaseFirestore get instance => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get userDoc =>
      usersCol.doc(AuthService.to.instance.currentUser!.uid);

  DocumentReference<Map<String, dynamic>> get usersStatsDoc =>
      usersCol.doc('---stats---');

  DocumentReference<Map<String, dynamic>> get vaultsStatsDoc =>
      vaultsCol.doc('---stats---');

  // INIT

  @override
  void onInit() {
    sharedVaults = vaultsCol.withConverter<SharedVault>(
      fromFirestore: (snapshot, _) => SharedVault.fromSnapshot(snapshot),
      toFirestore: (object, _) => object.toJson(),
    );

    vaultMembers = vaultMembersCol.withConverter<VaultMember>(
      fromFirestore: (snapshot, _) => VaultMember.fromSnapshot(snapshot),
      toFirestore: (object, _) => object.toJson(),
    );

    super.onInit();
  }

  // FUNCTIONS
  // record the some metadata: created time and updated time, items count and files count
  // data will be used for airdrops, and other promotions
  Future<void> record({required int objects, required int totalSize}) async {
    if (!isFirebaseSupported) return console.warning('Not Supported');
    if (!Persistence.to.analytics.val) return;

    // TODO: calculate whole size
    final vaultFile = File(join(
      LisoPaths.hive!.path,
      '$kHiveBoxItems.hive',
    ));

    console.wtf('Doc ID: ${userDoc.id}');

    final data = {
      'userId': AuthService.to.instance.currentUser!.uid,
      'address': WalletService.to.longAddress,
      'updatedTime': FieldValue.serverTimestamp(),
      'metadata': {
        'app': await HiveMetadataApp.getJson(),
        'device': await HiveMetadataDevice.getJson(),
        "size": {
          'storage': totalSize,
          'vault': await vaultFile.length(),
        },
        'count': {
          'items': HiveItemsService.to.data.length,
          'groups': HiveGroupsService.to.data.length,
          'files': objects,
          'shared_vaults': SharedVaultsController.to.data.length,
          'joined_shared_vaults': 0,
        },
        'settings': {
          'sync': Persistence.to.canSync,
          'theme': Persistence.to.theme.val,
        },
      },
    };

    final batch = instance.batch();

    // add createdTime if it's the first time this user is recorded
    if (!(await userDoc.get()).exists) {
      data['createdTime'] = FieldValue.serverTimestamp();

      // update users collection stats counter
      batch.set(
        usersStatsDoc,
        {
          'count': FieldValue.increment(1),
          'updatedTime': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    // update user doc
    batch.set(
      userDoc,
      data,
      SetOptions(merge: true),
    );

    try {
      await batch.commit();
    } catch (e, s) {
      CrashlyticsService.to.record(FlutterErrorDetails(
        exception: e,
        stack: s,
      ));

      return console.error("error batch commit: $e");
    }

    console.wtf('recorded');
  }
}
