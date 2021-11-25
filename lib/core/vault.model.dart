import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:web3dart/credentials.dart';

class Vault {
  final Wallet? master;
  final List<VaultSeed> seeds;

  Vault({this.master, this.seeds = const []});

  factory Vault.fromJson(Map<String, dynamic> json, String password) => Vault(
        master: Wallet.fromJson(json["master"], password),
        seeds: List<VaultSeed>.from(
          json["seeds"].map((x) => VaultSeed.fromJson(x, password)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "master": master?.toJson(),
        "seeds": List<dynamic>.from(seeds.map((x) => x.toJson())),
      };
}

class VaultSeed {
  final HiveSeed? seed;
  final Wallet? wallet;

  VaultSeed({this.seed, this.wallet});

  factory VaultSeed.fromJson(Map<String, dynamic> json, String password) =>
      VaultSeed(
        seed: HiveSeed.fromJson(json['seed']),
        wallet: Wallet.fromJson(json["wallet"], password),
      );

  Map<String, dynamic> toJson() => {
        "seed": seed?.toJson(),
        "wallet": wallet?.toJson(),
      };
}
