import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'shared_vault.hive.g.dart';

@HiveType(typeId: 30)
class HiveSharedVault extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final Uint8List cipherKey;

  HiveSharedVault({
    this.id = '',
    required this.cipherKey,
  });

  factory HiveSharedVault.fromJson(Map<String, dynamic> json) =>
      HiveSharedVault(
        id: json["id"],
        cipherKey: json["cipher_key"],
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": cipherKey,
    };
  }

  @override
  List<Object?> get props => [id, cipherKey];
}
