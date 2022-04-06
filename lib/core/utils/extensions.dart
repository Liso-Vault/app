// DISTINCT LIST
import 'package:web3dart/web3dart.dart';

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> distinctBy(Object Function(T e) getCompareValue) {
    var result = <T>[];

    for (var element in this) {
      if (!result.any((x) => getCompareValue(x) == getCompareValue(element))) {
        result.add(element);
      }
    }

    return result;
  }
}

extension WalletExtension on Wallet {
  String get address => privateKey.address.hexEip55;
}
