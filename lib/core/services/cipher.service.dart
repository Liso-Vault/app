import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:path/path.dart';

import '../utils/globals.dart';

class CipherService extends GetxService with ConsoleMixin {
  static CipherService get to => Get.find();

  // VARIABLES
  final iv = IV.fromLength(16);

  // GETTERS
  Key get key => Key.fromBase64(base64Encode(Globals.encryptionKey!));
  Encrypter get encrypter => Encrypter(AES(key));

  // FUNCTIONS
  // Cipher Bytes
  Uint8List encrypt(List<int> bytes) {
    return encrypter.encryptBytes(bytes, iv: iv).bytes;
  }

  List<int> decrypt(Uint8List bytes) {
    return encrypter.decryptBytes(Encrypted(bytes), iv: iv);
  }

  // Cipher Files
  Future<File> encryptFile(File file) async {
    final output = encrypt(await file.readAsBytes());

    final outputFile = File(join(
      LisoPaths.temp!.path,
      basename(file.path) + kEncryptedExtensionExtra,
    ));

    return await outputFile.writeAsBytes(output);
  }

  Future<File> decryptFile(File file) async {
    final output = decrypt(await file.readAsBytes());

    final outputFile = File(join(
      LisoPaths.temp!.path,
      basename(file.path).replaceAll(kEncryptedExtensionExtra, ''),
    ));

    return await outputFile.writeAsBytes(output);
  }
}
