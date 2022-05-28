import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive_groups.service.dart';
import 'package:liso/core/hive/hive_items.service.dart';
import 'package:liso/core/hive/hive_shared_vaults.service.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path/path.dart';

import '../../features/wallet/wallet.service.dart';
import '../hive/models/metadata/app.hive.dart';
import '../hive/models/metadata/device.hive.dart';
import 'crashlytics.service.dart';

class FirestoreService extends GetxService with ConsoleMixin {
  static FirestoreService get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // GETTERS
  FirebaseFirestore get instance => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersRef =>
      instance.collection('users');

  DocumentReference<Map<String, dynamic>> get userRef =>
      usersRef.doc(WalletService.to.longAddress);

  DocumentReference<Map<String, dynamic>> get usersStatsRef =>
      usersRef.doc('---stats---');

  CollectionReference<Map<String, dynamic>> get vaultsRef =>
      instance.collection('shared_vaults');

  DocumentReference<Map<String, dynamic>> get vaultsStatsRef =>
      vaultsRef.doc('---stats---');

  // INIT

  // FUNCTIONS
  // record the some metadata: created time and updated time, items count and files count
  // data will be used for airdrops, and other promotions
  void record({required int objects, required int totalSize}) async {
    if (!isFirebaseSupported) return console.warning('Not Supported');
    if (!Persistence.to.analytics.val) return;

    // TODO: calculate vault size for web
    final vaultFile = File(join(
      LisoPaths.hive!.path,
      '$kHiveBoxItems.hive',
    ));

    final data = {
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
          'shared_vaults': HiveSharedVaultsService.to.data.length,
        },
        'settings': {
          'sync': Persistence.to.canSync,
          'theme': Persistence.to.theme.val,
        },
      },
    };

    final batch = instance.batch();

    // add createdTime if it's the first time this user is recorded
    if (!(await userRef.get()).exists) {
      data['createdTime'] = FieldValue.serverTimestamp();

      // update users collection stats counter
      batch.set(
        usersStatsRef,
        {
          'count': FieldValue.increment(1),
          'updatedTime': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    // update user doc
    batch.set(
      userRef,
      data,
      SetOptions(merge: true),
    );

    try {
      batch.commit();
    } catch (e, s) {
      CrashlyticsService.to.record(FlutterErrorDetails(
        exception: e,
        stack: s,
      ));

      return console.error("error batch commit: $e");
    }

    console.info('recorded');
  }
}
