import 'package:hive/hive.dart';

import 'metadata.hive.dart';

part 'seed.hive.g.dart';

@HiveType(typeId: 0)
class HiveSeed extends HiveObject {
  @HiveField(0)
  String mnemonic;
  @HiveField(1)
  String address;
  @HiveField(2)
  String description;
  @HiveField(3)
  String ledger;
  @HiveField(4)
  String origin;
  @HiveField(5)
  HiveMetadata metadata;

  HiveSeed({
    required this.mnemonic,
    required this.address,
    required this.description,
    required this.ledger,
    required this.origin,
    required this.metadata,
  });

  factory HiveSeed.fromJson(Map<String, dynamic> json) => HiveSeed(
        mnemonic: json["mnemonic"],
        address: json["address"],
        description: json["description"],
        ledger: json["ledger"],
        origin: json["origin"],
        metadata: HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "mnemonic": mnemonic,
        "address": address,
        "description": description,
        "ledger": ledger,
        "origin": origin,
        "metadata": metadata.toJson(),
      };
}
