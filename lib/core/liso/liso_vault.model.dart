import 'dart:convert';

import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/liso/crypter.extensions.dart';
import 'package:liso/core/liso/liso_crypter.model.dart';
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

  Future<Map<String, dynamic>> toJsonEncrypted() async {
    final _seeds = List<dynamic>.from(
      seeds.map((x) => x.toJson()),
    );

    final encryptedSeeds = await LisoCrypter().encrypt(
      utf8.encode(jsonEncode(_seeds)),
    );

    return {
      "master": master?.toJson(),
      "seeds": encryptedSeeds.toJson(),
    };
  }

  Future<String> toJsonStringEncrypted() async =>
      jsonEncode(await toJsonEncrypted());
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
