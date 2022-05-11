import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/services/wallet.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/features/general/remote_image.widget.dart';
import 'package:liso/features/wallet/assets/assets.screen.dart';

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
          TextButton.icon(
            label: Row(
              mainAxisSize: MainAxisSize.max,
              children: const [
                Text('Ethereum'),
                SizedBox(width: 5),
                Icon(LineIcons.caretDown, size: 15),
              ],
            ),
            icon: const Icon(LineIcons.ethereum),
            onPressed: () {
              UIUtils.showSnackBar(
                title: 'Switch Networks',
                message: 'Coming soon...',
              );
            },
          ),
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '\$1,955',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '1,232,645.23 LISO',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  )
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
                    iconData: LineIcons.arrowCircleUp,
                    onPressed: () {},
                  ),
                  CardButton(
                    text: 'Receive',
                    iconData: LineIcons.arrowCircleDown,
                    onPressed: () {},
                  ),
                  CardButton(
                    text: 'Swap',
                    iconData: LineIcons.syncIcon,
                    onPressed: () {},
                  ),
                  CardButton(
                    text: 'Buy',
                    iconData: LineIcons.addToShoppingCart,
                    onPressed: () {},
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
              Tab(text: 'Transactions'),
            ],
          ),
          const SizedBox(height: 10),
          const Expanded(
            child: TabBarView(
              children: [
                AssetsScreen(),
                Icon(Icons.directions_transit),
              ],
            ),
          ),
        ],
      ),
    );

    final appBar = AppBar(
      title: Text('wallet'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        IconButton(
          icon: const Icon(LineIcons.qrcode),
          onPressed: () {},
        ),
        // IconButton(
        //   icon: const Icon(LineIcons.userCircle),
        //   onPressed: () {},
        // ),
        const SizedBox(width: 5),
      ],
    );

    // final fab = FloatingActionButton(
    //   child: const Icon(LineIcons.paperPlane),
    //   onPressed: () {
    //     UIUtils.showSnackBar(
    //       title: 'Send',
    //       message: 'Coming soon...',
    //     );
    //   },
    // );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBar,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            onTap: () {},
            child: Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        DiceBearAvatar(
                          seed: WalletService.to.address,
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
                              ),
                            ),
                            Text(
                              WalletService.to.shortAddress,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      ],
                    ),
                    const Icon(LineIcons.caretDown, size: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: content,
      ),
    );
  }
}

class CardButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Function()? onPressed;

  const CardButton({
    Key? key,
    required this.text,
    required this.iconData,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        children: [
          Icon(iconData, size: 30),
          const SizedBox(height: 5),
          Text(text),
        ],
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 15,
        ),
      ),
    );
  }
}
