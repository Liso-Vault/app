import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

import '../../../core/persistence/persistence.dart';

class NFTsScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static NFTsScreenController get to => Get.find();

  // VARIABLES
  final alchemy = Alchemy();

  // PROPERTIES
  final data = <EnhancedNFT>[].obs;

  // GETTERS

  // INIT
  @override
  void onReady() {
    load();
    super.onReady();
  }

  void load() async {
    change(null, status: RxStatus.loading());
    await loadNFTs();
    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());
  }

  Future<void> loadNFTs() async {
    final result = await alchemy.enhanced.nft.getNFTs(
      owner: Persistence.to.walletAddress.val,
    );

    result.fold(
      (error) => console.error(
        'Error: ${error.id} : ${error.error}',
      ),
      (response) async {
        data.value = response.ownedNfts;
      },
    );
  }
}
