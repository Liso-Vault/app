import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/shared_vaults/model/member.model.dart';

import '../../core/firebase/firestore.service.dart';
import 'model/shared_vault.model.dart';

class SharedVaultsController extends GetxController
    with ConsoleMixin, StateMixin {
  static SharedVaultsController get to => Get.find();

  // VARIABLES
  late StreamSubscription _streamShared, _streamJoined;

  // PROPERTIES
  final data = <QueryDocumentSnapshot<SharedVault>>[].obs;
  final joinedData = <QueryDocumentSnapshot<SharedVault>>[].obs;
  final busy = false.obs;

  // PROPERTIES

  // GETTERS

  // INIT

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  void restart() {
    _streamShared.cancel();
    _streamJoined.cancel();
    start();
    console.info('restarted');
  }

  void start() async {
    if (!isFirebaseSupported) return console.warning('Not Supported');

    _streamShared = FirestoreService.to.sharedVaults
        .where('userId', isEqualTo: AuthService.to.instance.currentUser!.uid)
        .orderBy('createdTime', descending: true)
        // .limit(_limit)
        .snapshots()
        .listen(
          _onDataShared,
          onError: _onError,
        );

    _streamJoined = FirestoreService.to.vaultMembers
        .where('userId', isEqualTo: AuthService.to.userId)
        .orderBy('createdTime', descending: true)
        // .limit(_limit)
        .snapshots()
        .listen(
          _onDataJoined,
          onError: _onError,
        );

    console.info('started');
  }

  void _onDataShared(QuerySnapshot<SharedVault>? snapshot) {
    if (snapshot == null || snapshot.docs.isEmpty) {
      change(null, status: RxStatus.empty());
      return data.clear();
    }

    data.value = snapshot.docs;
    change(null, status: RxStatus.success());
    console.wtf('shared vaults: ${data.length}');
  }

  void _onDataJoined(QuerySnapshot<VaultMember>? snapshot) async {
    if (snapshot == null || snapshot.docs.isEmpty) {
      joinedData.clear();
      return console.warning('not a member of any shared vaults');
    }

    final vaultIds = snapshot.docs.map((e) => e.reference.parent.parent!.id);

    final snapshots = await FirestoreService.to.sharedVaults
        .where(FieldPath.documentId, whereIn: vaultIds.toList())
        .get();

    joinedData.addAll(snapshots.docs);
    console.wtf('joined vaults: ${joinedData.length}');
  }

  void _onError(error) {
    console.error('stream error: $error');
    change(null, status: RxStatus.error('Failed to load: $error'));
  }

  Future<bool> exists(String name) async {
    final doc = await FirestoreService.to.sharedVaults
        .where('name', isEqualTo: name)
        .get();

    return doc.docs.isNotEmpty;
  }
}
