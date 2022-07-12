import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:humanizer/humanizer.dart';
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

          Widget title = Text('Just ${product.priceString} ${packageType.tr}');
          Widget? subTitle =
              product.description.isEmpty ? null : Text(product.description);
          Widget? secondary;

          if (product.introductoryPrice != null) {
            final intro = product.introductoryPrice!;
            final periodCycle = intro.cycles > 1
                ? '${intro.cycles} ${intro.periodUnit.name.tr}s'
                : intro.periodUnit.name.tr;

            title = RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Get.theme.textTheme.titleLarge?.color,
                ),
                children: [
                  TextSpan(text: product.priceString),
                  TextSpan(text: ' / ${intro.periodUnit.name.tr}'),
                ],
              ),
            );

            final percentageDifference_ =
                ((product.price - intro.price) / product.price) * 100;

            secondary = Text(
              '✔️ Save ${percentageDifference_.round()}%\nOr ${product.price - intro.price} ${product.currencyCode}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeColor,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            );

            subTitle = RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                children: [
                  const TextSpan(text: 'Start with '),
                  TextSpan(
                    text: intro.priceString,
                    style: TextStyle(
                      color: Get.theme.textTheme.bodyText1?.color,
                    ),
                  ),
                  TextSpan(text: ' on the first $periodCycle'),
                ],
              ),
            );
          }

          return Obx(
            () => RadioListTile<String>(
              title: title,
              subtitle: subTitle,
              value: package.identifier,
              secondary: secondary,
              groupValue: controller.identifier,
              activeColor: proColor,
              onChanged: (value) => controller.package.value =
                  ProController.to.packages.firstWhere(
                (e) => e.identifier == value,
              ),
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
                        ProController.to.packages.length > 1
                            ? 'Choose your plan'
                            : 'Unlock Powerful Features',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                      productsListView,
                      const SizedBox(height: 5),
                      ElevatedButton.icon(
                        onPressed: controller.purchase,
                        icon: const Icon(LineIcons.rocket),
                        label: const Text(
                          // 'Subscribe for ${controller.priceString}',
                          'Subscribe Now',
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: proColor,
                          visualDensity: VisualDensity.standard,
                        ),
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
      ],
    );

    final actionCard = Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
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
          const SizedBox(height: 5),
          Obx(
            () => Visibility(
              visible: controller.isSubscription,
              child: const Text(
                'Renews automatically. Cancel anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
          if (ProController.to.isFreeTrial) ...[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '✔️ Free Trial',
                style: TextStyle(fontSize: 12, color: proColor),
                children: [
                  TextSpan(
                    text:
                        ' is on and will expire on ${ProController.to.freeTrialExpirationDateTimeString}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(primary: proColor),
                onPressed: () => Utils.openUrl(
                  ConfigService.to.general.app.links.terms,
                ),
                child: const Text('Terms of Use'),
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
          const ProText(size: 23),
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
            PopupMenuItem<String>(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Iconsax.refresh, color: themeColor),
                  const SizedBox(width: 10),
                  const Text('Restore Purchases'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
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
