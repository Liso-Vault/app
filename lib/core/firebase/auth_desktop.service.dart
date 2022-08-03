import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/pro/pro.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:liso/core/persistence/persistence.dart' as p;

import '../../features/joined_vaults/joined_vault.controller.dart';
import '../../features/shared_vaults/shared_vault.controller.dart';
import 'auth.service.dart';
import 'crashlytics.service.dart';

class AuthDesktopService extends GetxService with ConsoleMixin {
  static AuthDesktopService get to => Get.find();

  // VARIABLES
  FirebaseAuth get instance => FirebaseAuth.instance;

  Map<String, dynamic> claims = {};

  // PROPERTIES

  // GETTERS
  User? get user => instance.currentUser;

  bool get isSignedIn => user != null;

  String get userId => user!.uid;

  // INIT
  @override
  void onInit() {
    instance.authStateChanges().listen((user_) async {
      if (user_ == null) {
        console.warning('signed out');
        SharedVaultsController.to.stop();
        JoinedVaultsController.to.stop();
        ProController.to.logout();
        // AnalyticsService.to.logSignOut();
      } else {
        console.info('signed in: ${user_.uid}');
        SharedVaultsController.to.start();
        JoinedVaultsController.to.start();
        ProController.to.login();

        // if (!GetPlatform.isWindows) {
        //   CrashlyticsService.to.instance.setUserIdentifier(userId);
        //   AnalyticsService.to.instance.setUserId(id: user_.uid);
        // }

        // AnalyticsService.to.logSignIn();

        // fetch custom claims
        user_
            .getIdTokenResult(true)
            .then((value) => claims = value.claims ?? {});

        // delay just to make sure everything is ready before we record
        await Future.delayed(2.seconds);
        AuthService.to.record();
      }
    });

    super.onInit();
  }

  // FUNCTIONS

  Future<void> signOut() async {
    await instance.signOut();
    console.info('signOut');
  }

  Future<void> signIn() async {
    if (isSignedIn) {
      AuthService.to.record(enforceDevices: true);
      return console.warning('Already Signed In: $userId');
    }

    final email = '${p.Persistence.to.walletAddress.val}@liso.dev';
    final password = await WalletService.to.sign(kAuthSignatureMessage);

    try {
      await instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      console.error('Code: ${e.code}, FirebaseAuthException: ${e.toString()}');

      if (e.code == 'user-not-found') {
        try {
          await instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (e, s) {
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
