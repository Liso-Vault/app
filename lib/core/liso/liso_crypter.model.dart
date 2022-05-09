// import 'dart:convert';

// import 'package:cryptography/cryptography.dart';
// import 'package:console_mixin/console_mixin.dart';
// import 'package:liso/core/utils/globals.dart';

// class LisoCrypter with ConsoleMixin {
//   // SINGLETON
//   static final LisoCrypter _singleton = LisoCrypter._internal();

//   // FACTORY
//   factory LisoCrypter() => _singleton;

//   // INTERNAL
//   late AesGcm algorithm;

//   LisoCrypter._internal() {
//     algorithm = AesGcm.with256bits();
//   }

//   // VARIABLES
//   SecretKey? secretKey;

//   Future<void> initSecretKey(List<int> bytes) async {
//     secretKey = await algorithm.newSecretKeyFromBytes(bytes);
//   }

//   Future<SecretBox> encrypt(List<int> clearText) async {
//     return await algorithm.encrypt(
//       clearText,
//       secretKey: secretKey!,
//       nonce: algorithm.newNonce(),
//       aad: utf8.encode(kAad),
//     );
//   }

//   Future<List<int>> decrypt(SecretBox secretBox) async {
//     return await algorithm.decrypt(
//       secretBox,
//       secretKey: secretKey!,
//       aad: utf8.encode(kAad),
//     );
//   }
// }
