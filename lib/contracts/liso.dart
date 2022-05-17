import 'dart:convert';

import 'package:liso/contracts/liso.abi.dart';
import 'package:web3dart/web3dart.dart';

const kTokenName = 'Liso';
const kTokenSymbol = 'LISO';
const kPolygonMumbaiContractAddress =
    '0x84bC9a7a80f41497e553ac49F3D6E10cA1B7Baea';

class LisoToken {
  // SINGLETON
  static final LisoToken _singleton = LisoToken._internal();

  // FACTORY
  factory LisoToken() => _singleton;

  // VARIABLES
  late DeployedContract polygonMumbaiContract;

  // CONSTRUCTOR
  LisoToken._internal() {
    polygonMumbaiContract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(kLisoAbiJson), kTokenName),
      EthereumAddress.fromHex(kPolygonMumbaiContractAddress),
    );
  }
}
