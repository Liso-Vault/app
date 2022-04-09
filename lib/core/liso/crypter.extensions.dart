// import 'dart:convert';

// import 'package:cryptography/cryptography.dart';

// extension SecretBoxExtension on SecretBox {
//   static SecretBox fromJson(Map<String, dynamic> json) {
//     return SecretBox(
//       base64.decode(json['cipherText']).cast<int>(),
//       nonce: base64.decode(json['nonce']).cast<int>(),
//       mac: Mac(base64.decode(json['mac']).cast<int>()),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['cipherText'] = base64.encode(cipherText);
//     data['nonce'] = base64.encode(nonce);
//     data['mac'] = base64.encode(mac.bytes);
//     return data;
//   }

//   String toJsonEncoded() => jsonEncode(toJson());
// }
