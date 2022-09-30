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
import 'package:liso/features/pro/upgrade/feature.tile.dart';

import '../../../core/firebase/config/config.service.dart';
import '../../../core/persistence/persistence.dart';
import '../../../core/utils/utils.dart';
import '../../app/routes.dart';
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
            const Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                'Unlock All Access',
                style: TextStyle(color: Colors.grey),
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
            FeatureTile(
              iconData: Iconsax.document,
              title: 'Items',
              trailing: Text(
                _formatKNumber(limit.items),
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.cpu,
              title: 'Devices',
              trailing: Text(
                _formatKNumber(limit.devices),
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.password_check,
              title: '2FA Authenticator',
              trailing: Icon(
                limit.otpGenerator ? Icons.check : LineIcons.times,
                color: limit.otpGenerator ? proColor : Colors.grey,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.document_cloud,
              title: 'Cloud Storage',
              trailing: Text(
                filesize(1073741824),
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.people,
              title: 'Shared Members',
              trailing: Text(
                _formatKNumber(limit.sharedMembers),
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.lock,
              title: 'Protected Items',
              trailing: Text(
                _formatKNumber(limit.protectedItems),
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.health,
              title: 'Password Health',
              trailing: Icon(
                limit.passwordHealth ? Icons.check : LineIcons.times,
                color: limit.passwordHealth ? proColor : Colors.grey,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.message_question,
              title: 'Priority Support',
              trailing: Icon(
                limit.prioritySupport ? Icons.check : LineIcons.times,
                color: limit.prioritySupport ? proColor : Colors.grey,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.security_card,
              title: 'File Encryption Tool',
              trailing: Icon(
                limit.cipherTool ? Icons.check : LineIcons.times,
                color: limit.cipherTool ? proColor : Colors.grey,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.direct_inbox,
              title: 'Vault Backups',
              trailing: Text(
                _formatKNumber(limit.backups),
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.weight,
              title: 'Upload File Size',
              trailing: Text(
                filesize(limit.uploadSize),
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.document_1,
              title: 'Uploaded Files',
              trailing: Text(
                _formatKNumber(limit.files),
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.trash,
              title: 'Undo Trash',
              trailing: Text(
                '${_formatKNumber(limit.trashDays)} Days',
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.box_1,
              title: 'Custom Vaults',
              trailing: Text(
                _formatKNumber(limit.customVaults),
                style: kTrailingStyle,
              ),
            ),
            FeatureTile(
              iconData: Iconsax.category,
              title: 'Custom Categories',
              trailing: Text(
                _formatKNumber(limit.customCategories),
                style: kTrailingStyle,
              ),
            ),
            // ListTile(
            //   trailing: Icon(
            //     limit.breachScanner ? Icons.check : LineIcons.times,
            //     color: limit.breachScanner ? proColor : Colors.grey,
            //   ),
            //   leading: Icon(Iconsax.scan, color: proColor),
            //   title: const Text('Breach Scanner'),
            //   onTap: () {},
            // ),
            // ListTile(
            //   trailing: Icon(
            //     limit.nfcKeycard ? Icons.check : LineIcons.times,
            //     color: limit.nfcKeycard ? proColor : Colors.grey,
            //   ),
            //   leading: Icon(Iconsax.card, color: proColor),
            //   title: const Text('NFC Keycard Support'),
            //   onTap: () {},
            // ),
            FeatureTile(
              iconData: Iconsax.rulerpen,
              title: 'Autosave + Autofill',
              trailing: Icon(Icons.check, color: proColor),
            ),
            FeatureTile(
              iconData: Iconsax.lock,
              title: 'Generate Passwords',
              trailing: Icon(Icons.check, color: proColor),
            ),
            FeatureTile(
              iconData: Iconsax.finger_cricle,
              title: 'Biometric Auth',
              trailing: Icon(Icons.check, color: proColor),
            ),
            FeatureTile(
              iconData: Iconsax.airplane,
              title: 'Offline Mode',
              trailing: Icon(Icons.check, color: proColor),
            ),
            FeatureTile(
              iconData: Iconsax.data,
              title: 'Self-Hostable',
              trailing: Icon(Icons.check, color: proColor),
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
          final product = package.storeProduct;
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

            title = Obx(
              () => RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.textTheme.titleLarge?.color,
                  ),
                  children: [
                    TextSpan(text: product.priceString),
                    TextSpan(text: ' / ${controller.periodUnitName.tr}'),
                  ],
                ),
              ),
            );

            final percentageDifference_ =
                ((product.price - intro.price) / product.price) * 100;

            secondary = Card(
              elevation: 1.0,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 5),
                child: Text(
                  controller.isFreeTrial
                      ? '${intro.periodNumberOfUnits} ${GetUtils.capitalizeFirst(intro.periodUnit.name)}\nFree Trial'
                      : '${percentageDifference_.round()}%\nOFF',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
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
                    style: const TextStyle(
                      color: kAppColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' on the first $periodCycle'),
                ],
              ),
            );

            if (controller.isFreeTrial) {
              final monthlyPrice = product.price / 12;
              final currencySymbol = product.priceString.substring(0, 1);

              subTitle = RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '$currencySymbol${currencyFormatter.format(monthlyPrice)}',
                      style: const TextStyle(color: kAppColor),
                    ),
                    const TextSpan(text: ' / month billed annually'),
                  ],
                ),
              );
            }
          }

          return Obx(
            () => RadioListTile<String>(
              title: title,
              subtitle: subTitle,
              value: package.identifier,
              secondary: secondary,
              groupValue: controller.identifier,
              activeColor: proColor,
              contentPadding: EdgeInsets.zero,
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
          Icon(Icons.check, color: proColor, size: 100),
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
        // temporarily remove until crypto features are matured
        // if (isCryptoSupported) ...[
        //   TabBar(
        //     tabs: controller.tabBarItems,
        //     onTap: (index) => controller.tabIndex.value = index,
        //     indicator: UnderlineTabIndicator(
        //       borderSide: BorderSide(color: proColor),
        //     ),
        //   ),
        //   const SizedBox(height: 10),
        // ],
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
                      // Text(
                      //   'Cancel anytime',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     color: proColor,
                      //     fontSize: 15,
                      //   ),
                      // ),
                      productsListView,
                      const SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: controller.purchase,
                        style: ElevatedButton.styleFrom(
                          primary: proColor,
                          visualDensity: VisualDensity.standard,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${controller.isFreeTrial ? 'Try Free' : 'Subscribe'} & Cancel Anytime',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (controller.isFreeTrial) ...[
                              const Text(
                                "We'll remind you before your trial ends",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "2 taps to start, super easy to cancel",
                        textAlign: TextAlign.center,
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
      color: Get.isDarkMode ? const Color(0xFF0B1717) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: controller.obx(
          (state) => actionCardContent,
          onLoading: BusyIndicator(color: proColor),
        ),
      ),
    );

    final content = Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: benefits),
          actionCard,
          // const SizedBox(height: 5),
          // if (ProController.to.isFreeTrial) ...[
          //   RichText(
          //     textAlign: TextAlign.center,
          //     text: TextSpan(
          //       text: '✔️ Free Trial',
          //       style: TextStyle(fontSize: 12, color: proColor),
          //       children: [
          //         TextSpan(
          //           text:
          //               ' is on and will expire on ${ProController.to.freeTrialExpirationDateTimeString}',
          //           style: const TextStyle(
          //             color: Colors.grey,
          //             fontSize: 12,
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          // ],
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  primary: proColor,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                onPressed: () => Utils.openUrl(
                  ConfigService.to.general.app.links.terms,
                ),
                child: const Text('Terms of Use'),
              ),
              const Text('|'),
              TextButton(
                style: TextButton.styleFrom(
                  primary: proColor,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                onPressed: () => Utils.openUrl(
                  ConfigService.to.general.app.links.privacy,
                ),
                child: const Text('Privacy Policy'),
              ),
              const Text('|'),
              TextButton(
                style: TextButton.styleFrom(
                  primary: proColor,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                onPressed: controller.restore,
                child: const Text('Restore Purchases'),
              ),
            ],
          ),
        ],
      ),
    );

    final appBar = AppBar(
      backgroundColor: Get.isDarkMode ? Colors.transparent : null,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Row(
        children: [
          Icon(LineIcons.rocket, color: proColor),
          const SizedBox(width: 7),
          const ProText(size: 23),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LineIcons.times),
          onPressed: () {
            Persistence.to.upgradeScreenShown.val = true;
            Get.back();
          },
        ),
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: const Text('Need Help ?'),
        ),
      ],
    );

    const darkDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Colors.black,
          Color(0xFF173030),
        ],
      ),
    );

    return Container(
      decoration: Get.isDarkMode ? darkDecoration : null,
      child: DefaultTabController(
        length: controller.tabBarItems.length,
        child: Scaffold(
          appBar: appBar,
          body: content,
          backgroundColor: Get.isDarkMode ? Colors.transparent : null,
        ),
      ),
    );
  }
}
