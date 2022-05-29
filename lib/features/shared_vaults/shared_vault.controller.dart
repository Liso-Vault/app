import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/firebase/firestore.service.dart';
import 'model/shared_vault.model.dart';

class SharedVaultsController extends GetxController
    with ConsoleMixin, StateMixin {
  static SharedVaultsController get to => Get.find();

  // VARIABLES
  late StreamSubscription _stream;

  // PROPERTIES
  final data = <QueryDocumentSnapshot<SharedVault>>[].obs;
  final busy = false.obs;

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    start();
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS

  void load() {
    //
  }

  void restart() {
    _stream.cancel();
    start();
  }

  void start() async {
    if (!isFirebaseSupported) return console.warning('Not Supported');

    _stream = FirestoreService.to.vaults
        .where('userId', isEqualTo: AuthService.to.user!.uid)
        .orderBy('createdTime', descending: true)
        // .limit(_limit)
        .snapshots()
        .listen(
          _onData,
          onError: _onError,
        );
  }

  void _onData(QuerySnapshot<SharedVault>? snapshot) {
    if (snapshot == null || snapshot.docs.isEmpty) {
      change(null, status: RxStatus.empty());
      data.clear();
    } else {
      data.value = snapshot.docs;
      change(null, status: RxStatus.success());
    }

    console.wtf('shared vaults: ${data.length}');
  }

  void _onError(error) {
    console.error('stream error: $error');
    change(null, status: RxStatus.error('Failed to load: $error'));
  }

  Future<bool> exists(String name) async {
    final doc = await FirestoreService.to.vaults
        .where(
          'name',
          isEqualTo: name,
        )
        .get();

    return doc.docs.isNotEmpty;
  }
}
