import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:web3dart/web3dart.dart';

import '../../../contracts/liso.dart';

class AssetsScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static AssetsScreenController get to => Get.find();

  // VARIABLES
  final alchemy = Alchemy();
  final lisoToken = LisoToken();
  final persistence = Get.find<PersistenceService>();

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onReady() {
    load();
    super.onReady();
  }

  void load() async {
    change(null, status: RxStatus.loading());
    await loadLiso();
    await loadMatic();
    change(null, status: RxStatus.success());
  }

  Future<void> loadLiso() async {
    final result = await alchemy.erc20.balanceOf(
      address: WalletService.to.address,
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

  Future<void> loadMatic() async {
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
