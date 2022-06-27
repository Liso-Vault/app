import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/pro.widget.dart';
import 'package:liso/features/pro/pro.controller.dart';

import '../../../core/firebase/config/config.service.dart';
import '../../../core/persistence/persistence.dart';
import '../../../core/utils/utils.dart';
import '../../general/appbar_leading.widget.dart';
import '../../general/busy_indicator.widget.dart';
import 'upgrade_screen.controller.dart';

class UpgradeScreen extends StatelessWidget with ConsoleMixin {
  const UpgradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpgradeScreenController());

    final benefits = Obx(
      () {
        final limit = controller.selectedLimit;

        String _formatKNumber(int number) {
          if (number == 1000000) {
            return 'Unlimited';
          } else {
            return kFormatter.format(number);
          }
        }

        final kTrailingStyle = TextStyle(
          color: proColor,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        );

        return ListView(
          shrinkWrap: true,
          controller: ScrollController(),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                'benefits'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            if (limit.id != 'pro' && limit.id != 'free') ...[
              ListTile(
                leading: Icon(Iconsax.coin, color: proColor),
                title: const Text('Min Token'),
                onTap: () {},
                trailing: Text(
                  '${currencyFormatter.format(limit.tokenThreshold)} \$LISO',
                  style: kTrailingStyle,
                ),
              ),
            ],
            ListTile(
              leading: Icon(Iconsax.document_cloud, color: proColor),
              title: const Text('Max Storage Size'),
              onTap: () {},
              trailing: Text(
                filesize(limit.storageSize),
                style: kTrailingStyle,
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.people, color: proColor),
              title: const Text('Max Shared Vault Members'),
              onTap: () {},
              trailing: Text(
                _formatKNumber(limit.sharedMembers),
                style: kTrailingStyle,
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.cpu, color: proColor),
              title: const Text('Max Devices'),
              onTap: () {},
              trailing: Text(
                _formatKNumber(limit.devices),
                style: kTrailingStyle,
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.key, color: proColor),
              title: const Text('Encrypted Files'),
              trailing: Text(
                _formatKNumber(limit.encryptedFiles),
                style: kTrailingStyle,
              ),
              onTap: () {},
            ),
            ListTile(
              trailing: Icon(
                limit.breachScanner ? LineIcons.check : LineIcons.times,
                color: limit.breachScanner ? proColor : Colors.grey,
              ),
              leading: Icon(Iconsax.scan, color: proColor),
              title: const Text('Breach Scanner'),
              onTap: () {},
            ),
            ListTile(
              trailing: Icon(
                limit.passwordHealth ? LineIcons.check : LineIcons.times,
                color: limit.passwordHealth ? proColor : Colors.grey,
              ),
              leading: Icon(Iconsax.health, color: proColor),
              title: const Text('Password Health'),
              onTap: () {},
            ),
            ListTile(
              trailing: Icon(
                limit.otpGenerator ? LineIcons.check : LineIcons.times,
                color: limit.otpGenerator ? proColor : Colors.grey,
              ),
              leading: Icon(Iconsax.password_check, color: proColor),
              title: const Text('OTP Generator'),
              onTap: () {},
            ),
            ListTile(
              trailing: Icon(
                limit.prioritySupport ? LineIcons.check : LineIcons.times,
                color: limit.prioritySupport ? proColor : Colors.grey,
              ),
              leading: Icon(
                Iconsax.message_question,
                color: proColor,
              ),
              title: const Text('Priority Support'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Iconsax.document, color: proColor),
              title: const Text('Max Items'),
              onTap: () {},
              trailing: Text(
                _formatKNumber(limit.items),
                style: kTrailingStyle,
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.shield_tick, color: proColor),
              title: const Text('Max Protected Items'),
              onTap: () {},
              trailing: Text(
                _formatKNumber(limit.protectedItems),
                style: kTrailingStyle,
              ),
            ),
            ListTile(
              trailing: Icon(
                limit.cipherTool ? LineIcons.check : LineIcons.times,
                color: limit.cipherTool ? proColor : Colors.grey,
              ),
              leading: Icon(Iconsax.security_card, color: proColor),
              title: const Text('Cipher Tool'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Iconsax.weight, color: proColor),
              title: const Text('Max Upload File Size'),
              onTap: () {},
              trailing: Text(
                filesize(limit.uploadSize),
                style: kTrailingStyle,
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.document_1, color: proColor),
              title: const Text('Max Files'),
              onTap: () {},
              trailing: Text(
                _formatKNumber(limit.files),
                style: kTrailingStyle,
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.import, color: proColor),
              title: const Text('Max Backups'),
              onTap: () {},
              trailing: Text(
                _formatKNumber(limit.backups),
                style: kTrailingStyle,
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.trash, color: proColor),
              title: const Text('Max Trash Due Days'),
              onTap: () {},
              trailing: Text(
                _formatKNumber(limit.trashDays),
                style: kTrailingStyle,
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.briefcase, color: proColor),
              title: const Text('Custom Vaults'),
              trailing: Text(
                _formatKNumber(limit.customVaults),
                style: kTrailingStyle,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Iconsax.briefcase, color: proColor),
              title: const Text('Custom Categories'),
              trailing: Text(
                _formatKNumber(limit.customCategories),
                style: kTrailingStyle,
              ),
              onTap: () {},
            ),
            ListTile(
              trailing: Icon(
                limit.nfcKeycard ? LineIcons.check : LineIcons.times,
                color: limit.nfcKeycard ? proColor : Colors.grey,
              ),
              leading: Icon(Iconsax.card, color: proColor),
              title: const Text('NFC Keycard'),
              onTap: () {},
            ),
          ],
        );
      },
    );

    final productsListView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        controller: ScrollController(),
        itemCount: ProController.to.packages.length,
        itemBuilder: (_, index) {
          final package = ProController.to.packages[index];
          final product = package.product;
          final packageType = package.packageType.name.toLowerCase();

          return Obx(
            () => RadioListTile<String>(
              title: Text('${product.priceString} ${packageType.tr}'),
              subtitle: Text(product.description),
              value: package.identifier,
              groupValue: controller.identifier.value,
              activeColor: proColor,
              onChanged: (value) => controller.identifier.value = value!,
            ),
          );
        },
      ),
    );

    final current = Center(
      child: Column(
        children: [
          Icon(LineIcons.check, color: proColor, size: 100),
          const SizedBox(height: 10),
          Text(
            controller.limitIndex == 1
                ? 'Thanks for staking ♥️'
                : 'Thanks for holding\n${currencyFormatter.format(Persistence.to.lastLisoBalance.val)} \$LISO ♥️',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    final actionCardContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCryptoSupported) ...[
          TabBar(
            tabs: controller.tabBarItems,
            onTap: (index) => controller.tabIndex.value = index,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: proColor),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (isPurchasesSupported) ...[
          Obx(
            () {
              final limit = controller.selectedLimit;
              final isCurrent =
                  controller.limitIndex == controller.tabIndex.value;
              final tokenThreshold = currencyFormatter.format(
                limit.tokenThreshold,
              );

              return IndexedStack(
                index: controller.tabIndex.value,
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Experience the full potential of ${ConfigService.to.appName} with Pro',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      productsListView,
                      const SizedBox(height: 5),
                      ElevatedButton.icon(
                        label: const Text('Subscribe'),
                        icon: const Icon(LineIcons.rocket),
                        style: ElevatedButton.styleFrom(primary: proColor),
                        onPressed: controller.purchase,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isCurrent) ...[
                        current,
                      ] else ...[
                        Text(
                          'Stake a minimum of $tokenThreshold \$LISO and enjoy the above Pro features',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        const Divider(height: 10),
                        ElevatedButton.icon(
                          label: const Text('Stake \$LISO'),
                          icon: const Icon(Iconsax.lock),
                          style: ElevatedButton.styleFrom(primary: proColor),
                          onPressed: () {
                            UIUtils.showSimpleDialog(
                              'Stake \$LISO Tokens',
                              'Coming soon...',
                            );
                          },
                        ),
                      ]
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isCurrent) ...[
                        current,
                      ] else ...[
                        Text(
                          'Hold at least $tokenThreshold \$LISO and enjoy the above Pro features',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        const Divider(height: 10),
                        ElevatedButton.icon(
                          label: const Text('Buy \$LISO'),
                          icon: const Icon(Iconsax.bitcoin_card),
                          style: ElevatedButton.styleFrom(primary: proColor),
                          onPressed: () {
                            UIUtils.showSimpleDialog(
                              'Buy \$LISO Tokens',
                              'Coming soon...',
                            );
                          },
                        ),
                      ]
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Keep the free version because it is awesome anyway',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const Divider(height: 10),
                      ElevatedButton.icon(
                        label: Text('Keep ${ConfigService.to.appName} Free'),
                        icon: const Icon(LineIcons.heart),
                        style: ElevatedButton.styleFrom(primary: proColor),
                        onPressed: Get.back,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ] else ...[
          Card(
            child: ListTile(
              leading: const Icon(LineIcons.infoCircle, color: Colors.orange),
              title: const Text(
                'Purchases unsupported on Windows',
                style: TextStyle(color: Colors.orange),
              ),
              subtitle: Text(
                'However, you can purchase on an Android, iOS or MacOS device and ${ConfigService.to.appName} will automatically detect it on Windows',
              ),
              onTap: () {
                // TODO: show some message
              },
            ),
          )
        ],
        const SizedBox(height: 10),
        if (ProController.to.isFreeTrial) ...[
          Card(
            child: ListTile(
              dense: true,
              leading: Icon(LineIcons.check, color: proColor),
              title: Text(
                'Free trial is active',
                style: TextStyle(color: proColor),
              ),
              subtitle: Text(
                'Expires on ${ProController.to.freeTrialExpirationDateTimeString}',
              ),
              onTap: () {
                // TODO: show some message
              },
            ),
          )
        ],
      ],
    );

    final actionCard = Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: controller.obx(
          (state) => actionCardContent,
          onLoading: BusyIndicator(color: proColor),
        ),
      ),
    );

    final content = Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: benefits),
          actionCard,
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(primary: proColor),
                onPressed: () => Utils.openUrl(
                  ConfigService.to.general.app.links.terms,
                ),
                child: const Text('Terms of Service'),
              ),
              const Text('and'),
              TextButton(
                style: TextButton.styleFrom(primary: proColor),
                onPressed: () => Utils.openUrl(
                  ConfigService.to.general.app.links.privacy,
                ),
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
        ],
      ),
    );

    final appBar = AppBar(
      leading: const AppBarLeadingButton(),
      centerTitle: false,
      title: Row(
        children: [
          Icon(LineIcons.rocket, color: proColor),
          const SizedBox(width: 7),
          const ProText(size: 18),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(LineIcons.verticalEllipsis),
          onSelected: (item) {
            if (item == 'restore') {
              controller.restore();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'restore',
              child: Text('Restore'),
            ),
          ],
        )
      ],
    );

    return DefaultTabController(
      length: controller.tabBarItems.length,
      child: Scaffold(
        appBar: appBar,
        body: content,
      ),
    );
  }
}