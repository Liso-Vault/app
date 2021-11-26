import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:web3dart/credentials.dart';

class LisoVault {
  final Wallet? master;
  final List<VaultSeed> seeds;

  LisoVault({this.master, this.seeds = const []});

  factory LisoVault.fromJson(Map<String, dynamic> json, String password) =>
      LisoVault(
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