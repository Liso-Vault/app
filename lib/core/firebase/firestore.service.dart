import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/auth_desktop.service.dart';
import 'package:liso/core/firebase/functions.service.dart';
import 'package:liso/core/firebase/model/user.model.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/groups/groups.service.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/joined_vaults/joined_vault.controller.dart';
import 'package:liso/features/shared_vaults/model/shared_vault.model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../features/app/routes.dart';
import '../../features/categories/categories.service.dart';
import '../../features/joined_vaults/model/member.model.dart';
import '../../features/pro/pro.controller.dart';
import '../../features/shared_vaults/shared_vault.controller.dart';
import '../../features/wallet/wallet.service.dart';
import '../hive/models/metadata/app.hive.dart';
import '../hive/models/metadata/device.hive.dart';
import '../services/cipher.service.dart';
import 'crashlytics.service.dart';

const kSharedVaultsCollection = 'shared_vaults';
const kVaultMembersCollection = 'members';
const kUsersCollection = 'users';
const kStatsDoc = '---stats---';

class FirestoreService extends GetxService with ConsoleMixin {
  static FirestoreService get to => Get.find();

  // VARIABLES
  final usersCol = FirebaseFirestore.instance.collection(
    kUsersCollection,
  );

  final vaultsCol = FirebaseFirestore.instance.collection(
    kSharedVaultsCollection,
  );

  final vaultMembersCol = FirebaseFirestore.instance.collectionGroup(
    kVaultMembersCollection,
  );

  late CollectionReference<FirebaseUser> users;

  late CollectionReference<SharedVault> sharedVaults;

  late CollectionReference<HiveMetadataDevice> userDevices;

  late Query<VaultMember> vaultMembers;

  // PROPERTIES

  // GETTERS
  FirebaseFirestore get instance => FirebaseFirestore.instance;

  DocumentReference<FirebaseUser> get userDoc =>
      users.doc(AuthService.to.userId);

  DocumentReference<Map<String, dynamic>> get usersStatsDoc =>
      usersCol.doc(kStatsDoc);

  DocumentReference<Map<String, dynamic>> get vaultsStatsDoc =>
      vaultsCol.doc(kStatsDoc);

  // INIT
  @override
  void onInit() {
    if (kUseFirebaseEmulator) {
      instance.useFirestoreEmulator(kFirebaseHost, kFirebaseFirestorePort);
    }

    users = usersCol.withConverter<FirebaseUser>(
      fromFirestore: (snapshot, _) => FirebaseUser.fromSnapshot(snapshot),
      toFirestore: (object, _) => object.toFirestoreJson(),
    );

    sharedVaults = vaultsCol.withConverter<SharedVault>(
      fromFirestore: (snapshot, _) => SharedVault.fromSnapshot(snapshot),
      toFirestore: (object, _) => object.toFirestoreJson(),
    );

    vaultMembers = vaultMembersCol.withConverter<VaultMember>(
      fromFirestore: (snapshot, _) => VaultMember.fromSnapshot(snapshot),
      toFirestore: (object, _) => object.toFirestoreJson(),
    );

    userDevices = userDoc.collection('devices').withConverter(
          fromFirestore: (snapshot, _) =>
              HiveMetadataDevice.fromSnapshot(snapshot),
          toFirestore: (object, _) => object.toJson(),
        );

    super.onInit();
  }

  // FUNCTIONS
  // record created time and updated time, items count and files count
  // data will be used for airdrops, and other promotions
  Future<void> syncUser({
    required int filesCount,
    required int encryptedFilesCount,
    required int totalSize,
    bool enforceDevices = false,
  }) async {
    // just to make sure
    if (!AuthService.to.isSignedIn) await AuthService.to.signIn();
    // check one more time
    if (!AuthService.to.isSignedIn) return console.warning('Not Signed In');

    if (!GetPlatform.isWindows && enforceDevices) {
      final devicesSnapshot = await FirestoreService.to.userDevices.get();
      final devices = devicesSnapshot.docs.map((e) => e.data()).toList();
      final foundDevices =
          devices.where((e) => e.id == Globals.metadata?.device.id);
      final totalDevices = devices.length + (foundDevices.isEmpty ? 1 : 0);

      if (totalDevices > ProController.to.limits.devices) {
        // open a locked page to manage devices and with button to upgrade
        return Get.toNamed(
          Routes.devices,
          parameters: {'enforce': 'true'},
          preventDuplicates: true,
        );
      }
    }

    final persistence = Get.find<Persistence>();

    // calculate vault byte size
    final encryptedVaultBytes = CipherService.to.encrypt(
      utf8.encode(await LisoManager.compactJson()),
    );

    var user = FirebaseUser();

    if (GetPlatform.isWindows) {
      final result = await FunctionsService.to.getUser(
        AuthDesktopService.to.userId,
      );

      result.fold(
        (error) => console.error(error),
        (response) => user = response,
      );

      // manually sync purchases
      if (user.purchases?.rcPurchaserInfo != null) {
        ProController.to.info.value = PurchaserInfo.fromJson(
          user.purchases!.rcPurchaserInfo!.toJson(),
        );
      }
    } else {
      final fetchedUser = await userDoc.get();

      if (fetchedUser.exists) {
        user = fetchedUser.data()!;
      }
    }

    if (user.docId.isNotEmpty) {
      persistence.lastServerDateTime.val =
          user.updatedTime!.toDate().toIso8601String();
    }

    final device = await HiveMetadataDevice.get();

    final metadata = FirebaseUserMetadata(
      app: await HiveMetadataApp.get(),
      deviceId: device.id,
      size: FirebaseUserSize(
        storage: totalSize,
        vault: encryptedVaultBytes.length,
      ),
      count: FirebaseUserCount(
        items: ItemsService.to.data.length,
        groups: GroupsService.to.data.length,
        categories: CategoriesService.to.data.length,
        files: filesCount,
        encryptedFiles: encryptedFilesCount,
        sharedVaults: SharedVaultsController.to.data.length,
        joinedVaults: JoinedVaultsController.to.data.length,
      ),
      settings: FirebaseUserSettings(
        sync: persistence.sync.val,
        theme: persistence.theme.val,
        syncProvider: persistence.syncProvider.val,
        biometrics: persistence.biometrics.val,
        analytics: persistence.analytics.val,
        crashReporting: persistence.crashReporting.val,
        backedUpSeed: persistence.backedUpSeed.val,
        backedUpPassword: persistence.backedUpPassword.val,
        localeCode: persistence.localeCode.val,
      ),
    );

    user.userId = AuthService.to.userId;
    user.address = WalletService.to.longAddress;
    user.limits = ProController.to.limits.id;
    user.metadata = metadata;

    if (!GetPlatform.isWindows) {
      user.purchases = FirebaseUserPurchases(
        rcPurchaserInfo: await Purchases.getPurchaserInfo(),
      );
    }

    if (GetPlatform.isWindows) {
      final result = await FunctionsService.to.setUser(user, device);

      return result.fold(
        (error) => console.error('failed to record'),
        (response) => console.wtf('recorded: $response'),
      );
    } else {
      final batch = instance.batch();

      // if new user
      if (user.createdTime == null) {
        // update users collection stats counter
        batch.set(
          usersStatsDoc,
          {
            'count': FieldValue.increment(1),
            'userId': user.userId,
            'updatedTime': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      // update user doc
      batch.set(userDoc, user, SetOptions(merge: true));
      // record user device
      batch.set(userDevices.doc(device.id), device);

      // commit batch
      try {
        await batch.commit();
      } catch (e, s) {
        CrashlyticsService.to.record(e, s);
        return console.error("error batch commit: $e");
      }
    }

    console.wtf('recorded');
  }
}
