import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../features/shared_vaults/shared_vault.controller.dart';

class AuthService extends GetxService with ConsoleMixin {
  static AuthService get to => Get.find();

  // VARIABLES
  FirebaseAuth get instance => FirebaseAuth.instance;
  User? user;

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    if (!isFirebaseSupported) return console.warning('Not Supported');

    instance.authStateChanges().listen((user_) {
      user = user_;

      if (user == null) {
        console.warning('signed out');
      } else {
        console.info('signed in: ${user!.uid}');
        SharedVaultsController.to.start();
      }
    });

    super.onInit();
  }

  // FUNCTIONS
  Future<void> signIn() async {
    if (!isFirebaseSupported) return console.warning('Not Supported');

    if (instance.currentUser != null) {
      return console.warning('Already Signed In');
    }

    final email = '${WalletService.to.longAddress}@liso.dev';
    final password = await WalletService.to.sign(kAuthSignatureMessage);

    try {
      await instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      console.error('FirebaseAuthException: $e');

      if (e.code == 'email-already-in-use') {
        try {
          await instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (e) {
          console.error('FirebaseAuth signIn error: $e');
        }
      }
    } catch (e) {
      console.error('FirebaseAuth signUp error: $e');
    }
  }
}
