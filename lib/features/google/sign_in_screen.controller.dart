import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/google/auth_client.dart';

import '../../core/utils/globals.dart';

class SignInScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignInScreenController());
  }
}

class SignInScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  // CONSTRUCTOR

  // STATIC

  // VARIABLES

  final _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void googleSignIn() async {
    // always ask for the google account to sign in
    if (await _googleSignIn.isSignedIn()) await _googleSignIn.signOut();

    GoogleSignInAccount? googleUser;

    try {
      googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      console.info("google signed in user: ${googleUser.email}");
    } catch (error) {
      return console.info("google sign in error: $error");
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await firebaseSignIn(credential, "credentials");
  }

  Future<void> firebaseSignIn(
      AuthCredential authCredential, String mode) async {
    change(null, status: RxStatus.loading());

    UserCredential credential;

    try {
      credential =
          await FirebaseAuth.instance.signInWithCredential(authCredential);
      console.info("authenticated");
    } on PlatformException catch (error) {
      console.info(
        "auth error! code: ${error.code}, details: ${error.details}, message: ${error.message}",
      );

      return change(null, status: RxStatus.error());
    }

    // IF NEWLY SIGNED UP USER
    if (credential.additionalUserInfo?.isNewUser == true) {
      //
    }

    // Finish authentication and exit
    change(null, status: RxStatus.success());
    // Get.back();
  }

  Future<void> list() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return;

    final list = await driveApi.files.list(
      spaces: 'appDataFolder',
      $fields:
          'files(kind,id,name,mimeType,createdTime,modifiedTime,headRevisionId)',
    );

    list.files?.forEach((e) async {
      console.info('${e.toJson()}');
    });

    console.info('files: ${list.files?.length}');
  }

  Future<void> upload() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return;

    // Master wallet address
    // final address = masterWallet!.privateKey.address.hexEip55;
    const address = 'New-0xE4EE69beaD8EF3E765AE6E15cD2Cf9a44E84EF26';

    // // Vault contents
    // final vaultSeeds = await compute(Isolates.seedsToWallets, {
    //   'encryptionKey': encryptionKey,
    //   'seeds': jsonEncode(HiveManager.seeds!.values.toList()),
    // });

    // if (vaultSeeds.isEmpty) return console.error('empty vault seeds');

    // final vault = LisoVault(
    //   master: masterWallet,
    //   seeds: vaultSeeds,
    // );

    // final contents = await vault.toJsonStringEncrypted();
    const contents = 'testing contents';

    final files = await driveApi.files.list(
      spaces: 'appDataFolder',
    );

    final cloudLisoFiles = files.files?.where((e) => e.name == '$address.liso');

    // Existing liso file in the cloud
    drive.File? existingLisoFile;
    if (cloudLisoFiles!.isNotEmpty) existingLisoFile = cloudLisoFiles.first;

    // Media contents
    final mediaStream =
        Future.value(contents.codeUnits).asStream().asBroadcastStream();
    final media = drive.Media(mediaStream, contents.length);

    // Uploaded liso file
    var uploadedLisoFile = drive.File();

    // New liso file
    var newLisoFile = drive.File();
    newLisoFile.name = '$address.$kVaultExtension';

    if (existingLisoFile == null) {
      // set the location to the appDataFolder
      newLisoFile.parents = ["appDataFolder"];

      uploadedLisoFile = await driveApi.files.create(
        newLisoFile,
        uploadMedia: media,
      );

      console.warning('created');
    } else {
      uploadedLisoFile = await driveApi.files.update(
        newLisoFile,
        existingLisoFile.id!,
        uploadMedia: media,
      );

      console.warning('updated');
    }

    console.info("Uploaded liso file: ${uploadedLisoFile.toJson()}");
  }

  Future<void> download() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return;

    final media = await driveApi.files.get(
      '1Cl6fsupnHHaBbQWZfUIl-Bgr5Lv2NVG9ufewMrlzlQF2rng2XQ',
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    console.info('media: ${media.contentType}');

    // final saveFile = File('${LisoManager.mainPath}/downloaded.liso');

    List<int> dataStore = [];

    media.stream.listen((data) {
      console.info("Received: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      console.warning('Content: ${utf8.decode(dataStore)}');
    }, onError: (error) {
      console.info("Error streaming media: $error");
    });
  }

  Future<void> empty() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return;

    final list = await driveApi.files.list(spaces: 'appDataFolder');

    list.files?.forEach((e) async {
      await driveApi.files.delete(e.id!);
    });

    console.info('Emptied!');
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final googleUser = await _googleSignIn.signIn();
    final headers = await googleUser?.authHeaders;

    if (headers == null) {
      console.error('sign in first');
      return null;
    }

    return drive.DriveApi(GoogleAuthClient(headers));
  }
}
