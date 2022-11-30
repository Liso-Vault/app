import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:app_core/connectivity/connectivity.service.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

import '../../contracts/liso.dart';
import '../../features/wallet/wallet.service.dart';
import '../firebase/model/config_web3.model.dart';
import '../persistence/persistence.dart';
import '../persistence/persistence.secret.dart';
import '../utils/globals.dart';

class AlchemyService extends GetxService with ConsoleMixin {
  static AlchemyService get to => Get.find();

  // VARIABLES
  final alchemy = Alchemy();
  final config = Get.find<ConfigService>();
  final wallet = Get.find<WalletService>();

  // GETTERS
  Chain get polygonChain => configWeb3.chains.first;

  // INIT

  // FUNCTIONS
  Future<void> reInit() async {
    await alchemy.stop();
    init();
  }

  void init() {
    final http = wallet.network.value == 'Polygon Testnet'
        ? polygonChain.test.http
        : polygonChain.main.http;

    final ws = wallet.network.value == 'Polygon Testnet'
        ? polygonChain.test.ws
        : polygonChain.main.ws;

    // Configuration
    alchemy.init(
      httpRpcUrl: http,
      wsRpcUrl: ws,
      verbose: false,
    );
  }

  Future<void> load() async {
    if (!WalletService.to.isSaved) return;

    if (!ConnectivityService.to.connected.value) {
      return console.warning('offline');
    }

    await loadLisoBalance();
    await loadMaticBalance();
  }

  Future<void> loadLisoBalance() async {
    if (!ConnectivityService.to.connected.value) {
      return console.warning('offline');
    }

    final lisoToken = LisoToken();

    final result = await alchemy.erc20.balanceOf(
      address: EthereumAddress.fromHex(SecretPersistence.to.walletAddress.val),
      contract: lisoToken.polygonMumbaiContract,
    );

    result.fold(
      (error) => console.error(
        'Error: ${error.code} : ${error.message}',
      ),
      (response) {
        AppPersistence.to.lastLisoBalance.val =
            response.getValueInUnit(EtherUnit.ether);
        console.info('liso balance: ${AppPersistence.to.lastLisoBalance.val}');
      },
    );
  }

  Future<void> loadMaticBalance() async {
    if (!ConnectivityService.to.connected.value) {
      return console.warning('offline');
    }

    final result = await alchemy.polygon.getBalance(
      address: SecretPersistence.to.walletAddress.val,
    );

    result.fold(
      (error) => console.error(
        'Error: ${error.code} : ${error.message}',
      ),
      (response) {
        AppPersistence.to.lastMaticBalance.val =
            response.getValueInUnit(EtherUnit.ether);
        console
            .info('matic balance: ${AppPersistence.to.lastMaticBalance.val}');
      },
    );
  }
}
