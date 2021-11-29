import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/liso/crypter.extensions.dart';
import 'package:liso/core/liso/liso_crypter.model.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/isolates.dart';
import 'package:web3dart/credentials.dart';

class LisoVault with ConsoleMixin {
  final Wallet? master;
  final List<VaultSeed> seeds;
  final int version;

  LisoVault({this.master, this.seeds = const [], this.version = 1});

  factory LisoVault.fromJson(Map<String, dynamic> json, String password) =>
      LisoVault(
        master: Wallet.fromJson(json["master"], password),
        seeds: List<VaultSeed>.from(
          json["seeds"].map((x) => VaultSeed.fromJson(x, password)),
        ),
        version: json["version"],
      );

  Map<String, dynamic> toJson() => {
        "master": master?.toJson(),
        "seeds": seeds,
        "version": version,
      };

  Future<Map<String, dynamic>> toJsonEncrypted() async {
    final _seeds = await compute(Isolates.fromJsonToList, seeds);

    final encryptedSeeds = await LisoCrypter().encrypt(
      utf8.encode(await compute(Isolates.iJsonEncode, _seeds)),
    );

    return {
      "master": master?.toJson(),
      "seeds": encryptedSeeds.toJson(),
      "version": version,
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
