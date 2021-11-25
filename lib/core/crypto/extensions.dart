import 'dart:convert';

import 'package:cryptography/cryptography.dart';

extension SecretBoxExtension on SecretBox {
  static SecretBox fromJson(Map<String, dynamic> json) {
    return SecretBox(
      json['cipherText'].cast<int>(),
      nonce: json['nonce'].cast<int>(),
      mac: Mac(json['mac'].cast<int>()),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['cipherText'] = cipherText;
    data['nonce'] = nonce;
    data['mac'] = mac.bytes;
    return data;
  }

  String toJsonEncoded() => jsonEncode(toJson());
}
