import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/analytics.service.dart';
import 'package:liso/core/firebase/auth_desktop.service.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/core/persistence/persistence.dart' as p;
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/pro/pro.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../features/joined_vaults/joined_vault.controller.dart';
import '../../features/files/s3.service.dart';
import '../../features/shared_vaults/shared_vault.controller.dart';
import 'firestore.service.dart';

class AuthService extends GetxService with ConsoleMixin {
  static AuthService get to => Get.find();

  // VARIABLES
  FirebaseAuth get instance => FirebaseAuth.instance;

  Map<String, dynamic> claims = {};

  // PROPERTIES

  // GETTERS
  dynamic get user =>
      GetPlatform.isWindows ? AuthDesktopService.to.user : instance.currentUser;

  bool get isSignedIn => user != null;

  String get userId => user!.uid;

  // INIT
  @override
  void onInit() {
    if (kUseFirebaseEmulator) {
      instance.useAuthEmulator(kFirebaseHost, kFirebaseAuthPort);
    }

    instance.authStateChanges().listen((user_) async {
      if (user_ == null) {
        console.warning('signed out');
        SharedVaultsController.to.stop();
        JoinedVaultsController.to.stop();
        ProController.to.logout();
        AnalyticsService.to.logSignOut();
      } else {
        console.info('signed in: ${user_.uid}');
        SharedVaultsController.to.start();
        JoinedVaultsController.to.start();
        ProController.to.login();

        if (!GetPlatform.isWindows) {
          CrashlyticsService.to.instance.setUserIdentifier(user_.uid);
          AnalyticsService.to.instance.setUserId(id: user_.uid);
        }

        AnalyticsService.to.logSignIn();
        // fetch custom claims
        user_
            .getIdTokenResult(true)
            .then((value) => claims = value.claims ?? {});
        // delay just to make sure everything is ready before we record
        await Future.delayed(2.seconds);
        record();
      }
    });

    super.onInit();
  }

  // FUNCTIONS
  void record({bool enforceDevices = false}) async {
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
    if (GetPlatform.isWindows) return AuthDesktopService.to.signOut();
    await instance.signOut();
    console.info('signOut');
  }

  Future<void> signIn() async {
    if (GetPlatform.isWindows) return AuthDesktopService.to.signIn();

    if (isSignedIn) {
      record(enforceDevices: true);
      return console.warning('Already Signed In: $userId');
    }

    final email = '${p.Persistence.to.walletAddress.val}@liso.dev';
    final password = await WalletService.to.sign(kAuthSignatureMessage);

    try {
      await instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e, s) {
      if (e.code == 'user-not-found') {
        try {
          await instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (e, s) {
          CrashlyticsService.to.record(e, s);
        }
      } else {
        CrashlyticsService.to.record(e, s);
      }
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
    }
  }
}
