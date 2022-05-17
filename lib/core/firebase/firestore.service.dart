import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path/path.dart';

import '../../features/wallet/wallet.service.dart';
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

  DocumentReference<Map<String, dynamic>> get userStatsRef =>
      usersRef.doc('---stats---');

  // INIT

  // FUNCTIONS
  // record the some metadata: created time and updated time, items count and files count
  // data will be used for airdrops, and other promotions
  void record({required int objects, required int totalSize}) async {
    if (!PersistenceService.to.analytics.val) return;

    // TODO: calculate vault size for web
    final vaultFile = File(join(
      LisoPaths.hive!.path,
      '$kHiveBoxItems.hive',
    ));

    final data = {
      'updatedTime': FieldValue.serverTimestamp(),
      'metadata': {
        "size": {
          'storage': totalSize,
          'vault': await vaultFile.length(),
        },
        'count': {
          'items': HiveManager.items!.length,
          'files': objects,
        },
        'settings': {
          'sync': PersistenceService.to.canSync,
          'theme': PersistenceService.to.theme.val,
        }
      },
    };

    final batch = instance.batch();

    // add createdTime if it's the first time this user is recorded
    if (!(await userRef.get()).exists) {
      data['createdTime'] = FieldValue.serverTimestamp();

      // update users collection stats counter
      batch.set(
        userStatsRef,
        {'count': FieldValue.increment(1)},
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
