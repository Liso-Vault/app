import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/resources/resources.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/services/wallet.service.dart';
import '../../core/utils/utils.dart';
import '../general/remote_image.widget.dart';
import 'wallet_screen.controller.dart';

class WalletScreen extends GetView<WalletScreenController> with ConsoleMixin {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: Styles.containerConstraints,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LineIcons.wallet),
            trailing: const Icon(LineIcons.copy),
            title: const Text('Wallet Address'),
            subtitle: Text(WalletService.to.shortAddress),
            onTap: () => Utils.copyToClipboard(WalletService.to.address),
          ),
          const Divider(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RemoteImage(
                    url: ConfigService.to.general.app.image,
                    height: 50,
                    placeholder: Image.asset(Images.logo, height: 25),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ability to send and receive, switch & manage networks, switch accounts, and more.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Divider(),
                  const Text(
                    'Still under development! Bug us if you are as excited as we are about this!\n🚀 🔥 😎',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('wallet'.tr),
        centerTitle: false,
        leading: const AppBarLeadingButton(),
      ),
      body: content,
    );
  }
}
