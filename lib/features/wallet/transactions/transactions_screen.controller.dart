import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

class TransactionsScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static TransactionsScreenController get to => Get.find();

  // VARIABLES
  final alchemy = Alchemy();

  // PROPERTIES
  final rawBalance = EtherAmount.zero().obs;
  final data = <EthTransactionReceipt>[].obs;

  // GETTERS
  double get balance => rawBalance.value.getValueInUnit(EtherUnit.ether);

  // INIT
  @override
  void onReady() {
    load();
    super.onReady();
  }

  Future<void> load() async {
    change(null, status: RxStatus.loading());
    await loadTransactions();
    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());
  }

  Future<void> loadTransactions() async {
    final result = await alchemy.polygon.getTransactionReceiptsByBlock(
      block: 'latest',
    );

    result.fold(
      (error) => console.error(
        'Error: ${error.code} : ${error.message}',
      ),
      (response) {
        console.info('transactions: ${response.length}');
        data.value = response;

        for (var e in response) {
          console.info(
              'type: ${e.type}, status: ${e.status}, from: ${e.from}, to: ${e.to}, contractAddress: ${e.contractAddress}, logs: ${e.logs.first.toJson()}');
        }
      },
    );
  }
}
