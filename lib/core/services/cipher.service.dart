import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:path/path.dart';

import '../utils/globals.dart';

class CipherService extends GetxService with ConsoleMixin {
  static CipherService get to => Get.find();

  // VARIABLES
  final iv = IV.fromLength(16);

  // GETTERS
  Key get key => Key(Persistence.to.cipherKey);
  Encrypter get encrypter => Encrypter(AES(key));

  // FUNCTIONS
  Uint8List encrypt(List<int> bytes, {Uint8List? cipherKey}) {
    if (cipherKey == null) {
      return encrypter.encryptBytes(bytes, iv: iv).bytes;
    } else {
      final key_ = Key(cipherKey);
      return Encrypter(AES(key_)).encryptBytes(bytes, iv: iv).bytes;
    }
  }

  List<int> decrypt(Uint8List bytes, {Uint8List? cipherKey}) {
    late Encrypter encrypter_;

    if (cipherKey == null) {
      encrypter_ = encrypter;
    } else {
      encrypter_ = Encrypter(AES(Key(cipherKey)));
    }

    return encrypter_.decryptBytes(Encrypted(bytes), iv: iv);
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
    final output = decrypt(await file.readAsBytes(), cipherKey: cipherKey);

    final outputFile = File(join(
      LisoPaths.temp!.path,
      basename(file.path).replaceAll(kEncryptedExtensionExtra, ''),
    ));

    return await outputFile.writeAsBytes(output);
  }

  // Checks
  Future<bool> canDecrypt(File file, Uint8List cipherKey) async {
    final key_ = Key(cipherKey);
    final encrypter_ = Encrypter(AES(key_));
    final bytes = await file.readAsBytes();

    try {
      encrypter_.decryptBytes(Encrypted(bytes), iv: iv);
    } catch (e) {
      console.error('Error Decrypting: $e');
      return false;
    }

    return true;
  }
}
