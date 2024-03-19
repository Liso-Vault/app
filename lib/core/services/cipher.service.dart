import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:path/path.dart';

import '../persistence/persistence.secret.dart';
import '../utils/globals.dart';

class CipherService extends GetxService with ConsoleMixin {
  static CipherService get to => Get.find();

  // VARIABLES
  final iv = IV.fromLength(16);

  // GETTERS

  // FUNCTIONS
  Uint8List encrypt(List<int> bytes, {Uint8List? cipherKey}) {
    final key = Key(cipherKey ?? SecretPersistence.to.cipherKey);
    // console.wtf('encrypt key: ${key.length}');
    final encrypter = Encrypter(AES(key));
    return encrypter.encryptBytes(bytes, iv: iv).bytes;
  }

  List<int> decrypt(Uint8List bytes, {Uint8List? cipherKey}) {
    final key = Key(cipherKey ?? SecretPersistence.to.cipherKey);
    // console.wtf('decrypt key: ${key.length}');
    final encrypter = Encrypter(AES(key));
    return encrypter.decryptBytes(Encrypted(bytes), iv: iv);
  }

  Future<File> encryptFile(
    File file, {
    Uint8List? cipherKey,
    bool addExtensionExtra = true,
  }) async {
    final output = encrypt(await file.readAsBytes(), cipherKey: cipherKey);

    final outputFile = File(join(
      LisoPaths.temp!.path,
      basename(file.path) + (addExtensionExtra ? kEncryptedExtensionExtra : ''),
    ));

    return await outputFile.writeAsBytes(output);
  }

  Future<File> decryptFile(File file, {Uint8List? cipherKey}) async {
    final bytes = decrypt(await file.readAsBytes(), cipherKey: cipherKey);

    final outputFile = File(
      join(
        LisoPaths.temp!.path,
        basename(file.path).replaceAll(kEncryptedExtensionExtra, ''),
      ),
    );

    return await outputFile.writeAsBytes(bytes);
  }

  // Checks
  Future<bool> canDecrypt(Uint8List bytes, Uint8List cipherKey) async {
    final encrypter_ = Encrypter(AES(Key(cipherKey)));

    try {
      encrypter_.decryptBytes(Encrypted(bytes), iv: iv);
    } catch (e) {
      console.error('Error Decrypting: $e');
      return false;
    }

    return true;
  }
}
