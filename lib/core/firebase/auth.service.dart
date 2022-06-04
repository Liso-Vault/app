import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../features/joined_vaults/joined_vault.controller.dart';
import '../../features/s3/s3.service.dart';
import '../../features/shared_vaults/shared_vault.controller.dart';
import 'firestore.service.dart';

class AuthService extends GetxService with ConsoleMixin {
  static AuthService get to => Get.find();

  // VARIABLES
  FirebaseAuth get instance => FirebaseAuth.instance;

  // PROPERTIES

  // GETTERS
  User? get user => instance.currentUser;

  bool get isSignedIn => user != null;

  String get userId => user!.uid;

  // INIT
  @override
  void onInit() {
    if (!isFirebaseSupported) return console.warning('Not Supported');

    instance.authStateChanges().listen((user_) async {
      if (user_ == null) {
        console.warning('signed out');
        SharedVaultsController.to.stop();
        JoinedVaultsController.to.stop();
      } else {
        console.info('signed in: ${user_.uid}');
        SharedVaultsController.to.start();
        JoinedVaultsController.to.start();
        // delay just to make sure everything is ready before we record
        await Future.delayed(2.seconds);
        _record();
      }
    });

    super.onInit();
  }

  // FUNCTIONS
  void _record({bool enforceDevices = false}) async {
    if (!WalletService.to.isReady) {
      return console.error('Cannot record because of null wallet');
    }

    final info = await S3Service.to.fetchStorageSize();
    if (info == null) return console.error('error storage info');

    await FirestoreService.to.syncUser(
      filesCount: info.contents.length,
      totalSize: info.totalSize,
      encryptedFilesCount: info.encryptedFiles,
      enforceDevices: enforceDevices,
    );
  }

  Future<void> signOut() async {
    await instance.signOut();
    console.info('signOut');
  }

  Future<void> signIn() async {
    if (!isFirebaseSupported) return console.warning('Not Supported');

    if (isSignedIn) {
      _record(enforceDevices: true);
      return console.warning('Already Signed In');
    }

    final email = '${WalletService.to.longAddress}@liso.dev';
    final password = await WalletService.to.sign(kAuthSignatureMessage);

    try {
      await instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e, s) {
      console.error('FirebaseAuthException: ${e.toString()}');

      if (e.code == 'user-not-found') {
        try {
          await instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (e) {
          console.error('FirebaseAuth signUp error: ${e.toString()}');
          CrashlyticsService.to.record(e, s);
        }
      }
    } catch (e, s) {
      console.error('FirebaseAuth signIn error: ${e.toString()}');
      CrashlyticsService.to.record(e, s);
    }
  }
}
