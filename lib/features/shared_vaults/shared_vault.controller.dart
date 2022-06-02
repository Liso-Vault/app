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
  final data = <SharedVault>[].obs;
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
    _stream.cancel();
    start();
    console.info('restarted');
  }

  void start() async {
    if (!isFirebaseSupported) return console.warning('Not Supported');

    _stream = FirestoreService.to.sharedVaults
        .where('userId', isEqualTo: AuthService.to.userId)
        .orderBy('createdTime', descending: true)
        // .limit(_limit)
        .snapshots()
        .listen(_onData, onError: _onError);

    console.info('started');
  }

  void _onData(QuerySnapshot<SharedVault>? snapshot) {
    if (snapshot == null || snapshot.docs.isEmpty) {
      change(null, status: RxStatus.empty());
      return data.clear();
    }

    data.value = snapshot.docs.map((e) => e.data()).toList();
    change(null, status: RxStatus.success());
    console.wtf('shared vaults: ${data.length}');
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
