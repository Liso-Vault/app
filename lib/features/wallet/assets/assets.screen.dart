import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/features/general/keep_alive.widget.dart';

import '../../../core/persistence/persistence.dart';
import '../../../core/persistence/persistence_builder.widget.dart';
import '../../../core/utils/globals.dart';
import '../../../resources/resources.dart';
import '../../general/busy_indicator.widget.dart';
import '../../general/centered_placeholder.widget.dart';
import '../wallet.service.dart';
import 'assets_screen.controller.dart';

class AssetsScreen extends GetView<AssetsScreenController> with ConsoleMixin {
  const AssetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final persistence = Get.find<Persistence>();
    final wallet = Get.find<WalletService>();

    final listView = PersistenceBuilder(
      builder: (p, context) {
        final liso = currencyFormatter.format(persistence.lastLisoBalance.val);
        final lisoUsd = currencyFormatter.format(wallet.lisoUsdBalance);

        final matic =
            currencyFormatter.format(persistence.lastMaticBalance.val);
        final maticUsd = currencyFormatter.format(wallet.maticUsdBalance);

        return ListView(
          shrinkWrap: true,
          controller: ScrollController(),
          children: [
            ListTile(
              leading: Image.asset(Images.logo, height: 18),
              trailing: const Icon(Iconsax.arrow_right_3),
              title: Text('$liso LISO'),
              subtitle: Text('\$$lisoUsd'),
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset(Images.polygon, height: 18),
              trailing: const Icon(Iconsax.arrow_right_3),
              title: Text('$matic MATIC'),
              subtitle: Text('\$$maticUsd'),
              onTap: () {},
            ),
          ],
        );
      },
    );

    final content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.image,
        message: 'No NFTs',
        child: TextButton.icon(
          icon: const Icon(Iconsax.refresh),
          onPressed: controller.load,
          label: Text(
            'refresh'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    return KeepAliveWrapper(child: content);
  }
}
