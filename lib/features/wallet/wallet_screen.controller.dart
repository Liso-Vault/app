import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/contracts/liso.dart';
import 'package:liso/core/services/alchemy.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/wallet/nfts/nfts_screen.controller.dart';
import 'package:liso/features/wallet/transactions/transactions_screen.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/persistence/persistence.secret.dart';
import '../../core/utils/utils.dart';
import '../../resources/resources.dart';
import '../menu/menu.item.dart';
import 'assets/assets_screen.controller.dart';

class WalletScreenController extends GetxController with ConsoleMixin {
  static WalletScreenController get to => Get.find();

  // VARIABLES
  final alchemy = Alchemy();
  final liso = LisoToken();

  // PROPERTIES

  // GETTERS
  List<ContextMenuItem> get networkMenuItems {
    return [
      ContextMenuItem(
        title: 'Polygon Mainnet',
        leading: Image.asset(Images.polygon, height: 18),
        onSelected: () {
          WalletService.to.network.value = 'Polygon Mainnet';
          reInit();
        },
      ),
      ContextMenuItem(
        title: 'Polygon Testnet',
        leading: Image.asset(Images.polygon, height: 18, color: Colors.grey),
        onSelected: () {
          WalletService.to.network.value = 'Polygon Testnet';
          reInit();
        },
      ),
    ];
  }

  // TODO: use connectivity plus to listen for network changes
  // once connected, automatically start alchemy socket

  // INIT
  @override
  void onInit() {
    Get.put(AssetsScreenController());
    Get.put(NFTsScreenController());
    Get.put(TransactionsScreenController());
    super.onInit();
  }

  // FUNCTIONS
  void reInit() async {
    await AlchemyService.to.reInit();
    load();
  }

  void load() {
    AssetsScreenController.to.load();
    NFTsScreenController.to.load();
    TransactionsScreenController.to.load();
  }

  void switchAccounts() {
    UIUtils.showSimpleDialog('Switch Accounts', 'Coming soon...');
  }

  void showQRCode() {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Center(
            child: QrImage(
              data: SecretPersistence.to.longAddress,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          SecretPersistence.to.longAddress,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () =>
              Utils.copyToClipboard(SecretPersistence.to.longAddress),
          icon: const Icon(Iconsax.copy),
          label: const Text('Copy Address'),
        ),
      ],
    );

    Get.dialog(AlertDialog(
      title: const Text('Receive'),
      content:
          Utils.isSmallScreen ? content : SizedBox(width: 450, child: content),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('close'.tr),
        ),
      ],
    ));
  }

  void test() async {
    final balance = await alchemy.erc20.balanceOf(
      contract: liso.polygonMumbaiContract,
      address: WalletService.to.address,
    );

    balance.fold(
      (error) => console.error(
        'Error: ${error.code} : ${error.message}',
      ),
      (response) {
        console.info('response: $response');
      },
    );

    final name = await alchemy.erc20.name(
      contract: liso.polygonMumbaiContract,
    );

    name.fold(
      (error) => console.error(
        'Error: ${error.code} : ${error.message}',
      ),
      (response) {
        console.info('response: $response');
      },
    );

    final symbol = await alchemy.erc20.symbol(
      contract: liso.polygonMumbaiContract,
    );

    symbol.fold(
      (error) => console.error(
        'Error: ${error.code} : ${error.message}',
      ),
      (response) {
        console.info('response: $response');
      },
    );

    // final balance = await liso.balanceOf(WalletService.to.address);
    // console.info('balance: $balance');

    // // Contract ABI
    // final param = contract!
    //     .function('balanceOf')
    //     .encodeCall([WalletService.to.address]);

    // final transaction = EthTransactionCall(
    //   to: kContractAddress,
    //   data: bytesToHex(param, include0x: true, padToEvenLength: true),
    // );

    // console.warning('transaction: ${transaction.toJson()}');

    // final result = await alchemy.polygon.call(
    //   call: transaction,
    // );

    // result.fold(
    //   (error) => console.error(
    //     'Error: ${error.code} : ${error.message}',
    //   ),
    //   (response) {
    //     console.info(response);
    //   },
    // );

    // // Alchemy Enhanced
    // final result = await alchemy.enhanced.token.getTokenBalances(
    //   address: WalletService.to.longAddress,
    //   contractAddresses: [kContractAddress],
    // );

    // result.fold(
    //   (error) => console.error(
    //     'Error: ${error.code} : ${error.message}',
    //   ),
    //   (response) async {
    //     // rawBalance.value = response;

    //     for (var e in response.tokenBalances) {
    //       final _result = await alchemy.enhanced.token.getTokenMetadata(
    //         address: e.contractAddress,
    //       );

    //       if (_result.isRight) {
    //         console.wtf(
    //           'name: ${_result.right.name}, name: ${_result.right.symbol}, name: ${_result.right.decimals}',
    //         );
    //       }

    //       console.info('balance: ${e.tokenBalance}');
    //     }
    //   },
    // );

    // // Web3dart call
    // final balance = await client.call(
    //   contract: liso.polygonMumbaiContract,
    //   function: liso.polygonMumbaiContract.function('name'),
    //   // params: [WalletService.to.address],
    //   params: [],
    // );

    // console.info('We have ${balance.first} Liso');
  }

  void signText() async {
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController();

    void _sign() async {
      if (!formKey.currentState!.validate()) return;

      final signature = await WalletService.to.sign(textController.text);

      UIUtils.showSimpleDialog(
        'Signature',
        signature,
        action: () => Utils.copyToClipboard(signature),
        actionText: 'Copy',
      );
    }

    final content = TextFormField(
      controller: textController,
      minLines: 1,
      maxLines: 5,
      validator: (data) => data!.isEmpty ? 'Required' : null,
      decoration: const InputDecoration(
        labelText: 'Text',
        hintText: 'Enter the text to sign',
      ),
    );

    Get.dialog(AlertDialog(
      title: Text('sign_text'.tr),
      content: Form(
        key: formKey,
        child: Utils.isSmallScreen
            ? content
            : SizedBox(width: 450, child: content),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: _sign,
          child: Text('sign'.tr),
        ),
      ],
    ));
  }
}
