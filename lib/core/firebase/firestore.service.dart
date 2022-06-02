import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/model/user.model.dart';
import 'package:liso/core/hive/hive_groups.service.dart';
import 'package:liso/core/hive/hive_items.service.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/joined_vaults/joined_vault.controller.dart';
import 'package:liso/features/shared_vaults/model/shared_vault.model.dart';

import '../../features/app/routes.dart';
import '../../features/joined_vaults/model/member.model.dart';
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
    users = usersCol.withConverter<FirebaseUser>(
      fromFirestore: (snapshot, _) => FirebaseUser.fromSnapshot(snapshot),
      toFirestore: (object, _) => object.toJson(),
    );

    sharedVaults = vaultsCol.withConverter<SharedVault>(
      fromFirestore: (snapshot, _) => SharedVault.fromSnapshot(snapshot),
      toFirestore: (object, _) => object.toJson(),
    );

    vaultMembers = vaultMembersCol.withConverter<VaultMember>(
      fromFirestore: (snapshot, _) => VaultMember.fromSnapshot(snapshot),
      toFirestore: (object, _) => object.toJson(),
    );

    userDevices = userDoc.collection('devices').withConverter(
          fromFirestore: (snapshot, _) =>
              HiveMetadataDevice.fromSnapshot(snapshot),
          toFirestore: (object, _) => object.toJson(),
        );

    super.onInit();
  }

  // FUNCTIONS
  // record the some metadata: created time and updated time, items count and files count
  // data will be used for airdrops, and other promotions
  Future<void> syncUser({
    required int filesCount,
    required int encryptedFilesCount,
    required int totalSize,
    bool enforceDevices = false,
  }) async {
    if (!isFirebaseSupported) return console.warning('Not Supported');
    // just to make sure
    if (!AuthService.to.isSignedIn) await AuthService.to.signIn();

    if (enforceDevices) {
      final devicesSnapshot = await FirestoreService.to.userDevices.get();
      final devices = devicesSnapshot.docs.map((e) => e.data()).toList();
      final foundDevices =
          devices.where((e) => e.id == Globals.metadata.device.id);
      final totalDevices = devices.length + (foundDevices.isEmpty ? 1 : 0);
      console.wtf('totalDevices: $totalDevices');

      if (totalDevices > WalletService.to.limits.devices) {
        // open a locked page to manage devices and with button to upgrade
        return Get.toNamed(
          Routes.devices,
          parameters: {'enforce': 'true'},
          preventDuplicates: true,
        );
      }
    }

    // calculate vault byte size
    final encryptedVaultBytes = CipherService.to.encrypt(
      utf8.encode(await LisoManager.compactJson()),
    );

    late FirebaseUser user;
    final fetchedUser = await userDoc.get();

    if (fetchedUser.exists) {
      user = fetchedUser.data()!;
    } else {
      user = FirebaseUser();
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
        items: HiveItemsService.to.data.length,
        groups: HiveGroupsService.to.data.length,
        files: filesCount,
        encryptedFiles: encryptedFilesCount,
        sharedVaults: SharedVaultsController.to.data.length,
        joinedVaults: JoinedVaultsController.to.data.length,
      ),
      settings: FirebaseUserSettings(
        sync: Persistence.to.canSync,
        theme: Persistence.to.theme.val,
      ),
    );

    user.userId = AuthService.to.userId;
    user.address = WalletService.to.longAddress;
    user.limits = WalletService.to.limits.id;
    user.metadata = metadata;

    final batch = instance.batch();

    // if new user
    if (user.createdTime == null) {
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

    console.wtf('recorded');
  }
}
