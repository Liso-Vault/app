import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/features/general/remote_image.widget.dart';
import 'package:liso/features/wallet/assets/assets.screen.dart';
import 'package:liso/features/wallet/transactions/transactions.screen.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/persistence/persistence_builder.widget.dart';
import '../../core/utils/utils.dart';
import '../../resources/resources.dart';
import '../general/card_button.widget.dart';
import '../menu/menu.button.dart';
import 'nfts/nfts.screen.dart';
import 'wallet_screen.controller.dart';

class WalletScreen extends GetView<WalletScreenController> with ConsoleMixin {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ContextMenuButton(
            controller.networkMenuItems,
            useMouseRegion: true,
            padding: EdgeInsets.zero,
            child: TextButton.icon(
              onPressed: () {},
              icon: Image.asset(Images.polygon, height: 18, color: themeColor),
              label: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Obx(() => Text(WalletService.to.network.value)),
                  const SizedBox(width: 5),
                  const Icon(LineIcons.caretDown, size: 15),
                ],
              ),
            ),
          ),
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PersistenceBuilder(
                    builder: (p, context) {
                      final totalUsd = currencyFormatter
                          .format(WalletService.to.totalUsdBalance);

                      return Text(
                        '\$$totalUsd',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const Text(
                    'TOTAL BALANCE',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CardButton(
                    text: 'Send',
                    iconData: Iconsax.send_sqaure_2,
                    onPressed: () {
                      UIUtils.showSimpleDialog('Send', 'Coming soon...');
                    },
                  ),
                  CardButton(
                    text: 'Receive',
                    iconData: Iconsax.receive_square_2,
                    onPressed: controller.showQRCode,
                  ),
                  CardButton(
                    text: 'Swap',
                    iconData: Iconsax.arrow_swap_horizontal,
                    onPressed: () =>
                        UIUtils.showSimpleDialog('Swap', 'Coming soon...'),
                  ),
                  CardButton(
                    text: 'Buy',
                    iconData: Iconsax.shopping_cart,
                    onPressed: () => UIUtils.showSimpleDialog(
                        'Buy Crypto', 'Coming soon...'),
                  ),
                  CardButton(
                    text: 'Signer',
                    iconData: Iconsax.pen_add,
                    onPressed: controller.signText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Get.theme.buttonTheme.colorScheme!.primary,
              ),
            ),
            tabs: const [
              Tab(text: 'Assets'),
              Tab(text: 'NFTs'),
              Tab(text: 'Activity'),
            ],
          ),
          const SizedBox(height: 10),
          const Expanded(
            child: TabBarView(
              children: [
                AssetsScreen(),
                NFTsScreen(),
                TransactionsScreen(),
              ],
            ),
          ),
          if (isBeta) ...[
            TextButton.icon(
              icon: const Icon(LineIcons.discord),
              label: const Text('Need Testnet \$LISO?'),
              onPressed: () => Utils.openUrl(
                ConfigService.to.general.app.links.discord,
              ),
            ),
          ]
        ],
      ),
    );

    final appBar = AppBar(
      title: Text('wallet'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.scan_barcode),
          onPressed: () {
            UIUtils.showSimpleDialog('Scan QR', 'Coming soon...');
          },
        ),
        const SizedBox(width: 5),
      ],
    );

    final bottomContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            DiceBearAvatar(
              seed: WalletService.to.longAddress,
              size: 30,
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account 1',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Utils.isDrawerExpandable
                      ? WalletService.to.shortAddress
                      : WalletService.to.longAddress,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
        const Icon(LineIcons.caretDown, size: 15),
      ],
    );

    final bottomBar = InkWell(
      onTap: controller.switchAccounts,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: bottomContent,
          ),
        ),
      ),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: appBar,
        bottomNavigationBar: bottomBar,
        body: content,
      ),
    );
  }
}
