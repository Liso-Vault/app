import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:web3dart/web3dart.dart';

import '../../contracts/liso.dart';
import '../../features/wallet/wallet.service.dart';
import '../firebase/config/config.service.dart';
import '../firebase/config/models/config_web3.model.dart';

class AlchemyService extends GetxService with ConsoleMixin {
  static AlchemyService get to => Get.find();

  // VARIABLES
  final alchemy = Alchemy();
  final persistence = Get.find<PersistenceService>();
  final config = Get.find<ConfigService>();
  final wallet = Get.find<WalletService>();

  // GETTERS
  Chain get polygonChain => config.web3.chains.first;

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
    await loadLisoBalance();
    await loadMaticBalance();
  }

  Future<void> loadLisoBalance() async {
    final alchemy = Alchemy();
    final lisoToken = LisoToken();

    final result = await alchemy.erc20.balanceOf(
      address: wallet.address,
      contract: lisoToken.polygonMumbaiContract,
    );

    result.fold(
      (error) => console.error(
        'Error: ${error.code} : ${error.message}',
      ),
      (response) {
        persistence.lastLisoBalance.val =
            response.getValueInUnit(EtherUnit.ether);
        console.info('liso balance: ${persistence.lastLisoBalance.val}');
      },
    );
  }

  Future<void> loadMaticBalance() async {
    final result = await alchemy.polygon.getBalance(
      address: WalletService.to.longAddress,
    );

    result.fold(
      (error) => console.error(
        'Error: ${error.code} : ${error.message}',
      ),
      (response) {
        persistence.lastMaticBalance.val =
            response.getValueInUnit(EtherUnit.ether);
        console.info('matic balance: ${persistence.lastMaticBalance.val}');
      },
    );
  }
}
