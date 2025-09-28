// import 'package:app_core/globals.dart';
// import 'package:app_core/pages/routes.dart';
// import 'package:app_core/persistence/persistence_builder.widget.dart';
// import 'package:app_core/utils/ui_utils.dart';
// import 'package:app_core/utils/utils.dart';
// import 'package:app_core/widgets/appbar_leading.widget.dart';
// import 'package:console_mixin/console_mixin.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:icons_plus/icons_plus.dart';
// import 'package:liso/core/utils/globals.dart';
// import 'package:liso/features/wallet/assets/assets.screen.dart';
// import 'package:liso/features/wallet/transactions/transactions.screen.dart';
// import 'package:liso/features/wallet/wallet.service.dart';

// import '../../core/persistence/persistence.secret.dart';
// import '../../resources/resources.dart';
// import '../general/card_button.widget.dart';
// import '../menu/menu.button.dart';
// import 'nfts/nfts.screen.dart';
// import 'wallet_screen.controller.dart';

// class WalletScreen extends StatelessWidget with ConsoleMixin {
//   const WalletScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(WalletScreenController());

//     final content = Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           ContextMenuButton(
//             controller.networkMenuItems,
//             useMouseRegion: true,
//             padding: EdgeInsets.zero,
//             child: TextButton.icon(
//               onPressed: () {},
//               icon: Image.asset(Images.polygon, height: 18, color: themeColor),
//               label: Row(
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Obx(() => Text(WalletService.to.network.value)),
//                   const SizedBox(width: 5),
//                   const Icon(LineAwesome.caret_down_solid, size: 15),
//                 ],
//               ),
//             ),
//           ),
//           Card(
//             elevation: 2.0,
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   PersistenceBuilder(
//                     builder: (p, context) {
//                       final totalUsd = currencyFormatter
//                           .format(WalletService.to.totalUsdBalance);

//                       return Text(
//                         '\$$totalUsd',
//                         style: const TextStyle(
//                           fontSize: 40,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       );
//                     },
//                   ),
//                   const Text(
//                     'TOTAL BALANCE',
//                     style: TextStyle(color: Colors.grey, fontSize: 10),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Card(
//             elevation: 2.0,
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   CardButton(
//                     text: 'Send',
//                     iconData: Iconsax.send_sqaure_2_outline,
//                     onPressed: () {
//                       UIUtils.showSimpleDialog('Send', 'Coming soon...');
//                     },
//                   ),
//                   CardButton(
//                     text: 'Receive',
//                     iconData: Iconsax.receive_square_2_outline,
//                     onPressed: controller.showQRCode,
//                   ),
//                   CardButton(
//                     text: 'Swap',
//                     iconData: Iconsax.arrow_swap_horizontal_outline,
//                     onPressed: () =>
//                         UIUtils.showSimpleDialog('Swap', 'Coming soon...'),
//                   ),
//                   CardButton(
//                     text: 'Buy',
//                     iconData: Iconsax.shopping_cart_outline,
//                     onPressed: () async {
//                       UIUtils.showSimpleDialog('Buy Crypto', 'Coming soon...');
//                     },
//                   ),
//                   CardButton(
//                     text: 'Signer',
//                     iconData: Iconsax.pen_add_outline,
//                     onPressed: controller.signText,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           TabBar(
//             indicator: UnderlineTabIndicator(
//               borderSide: BorderSide(
//                 color: Get.theme.buttonTheme.colorScheme!.primary,
//               ),
//             ),
//             tabs: const [
//               Tab(text: 'Assets'),
//               Tab(text: 'NFTs'),
//               Tab(text: 'Activity'),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Expanded(
//             child: TabBarView(
//               children: [
//                 AssetsScreen(),
//                 NFTsScreen(),
//                 TransactionsScreen(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );

//     final appBar = AppBar(
//       title: Text('${'wallet'.tr} (Alpha)'),
//       centerTitle: false,
//       leading: const AppBarLeadingButton(),
//       actions: [
//         IconButton(
//           icon: const Icon(Iconsax.scan_barcode_outline),
//           onPressed: () {
//             UIUtils.showSimpleDialog('Scan QR', 'Coming soon...');
//           },
//         ),
//         TextButton(
//           onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
//           child: const Text('Help ?'),
//         ),
//       ],
//     );

//     final bottomContent = Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             // TODO: temporary
//             // DiceBearAvatar(
//             //   seed: SecretPersistence.to.longAddress,
//             //   size: 30,
//             // ),
//             const SizedBox(width: 10),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Account 1',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   isSmallScreen
//                       ? SecretPersistence.to.shortAddress
//                       : SecretPersistence.to.longAddress,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             )
//           ],
//         ),
//         const Icon(LineAwesome.caret_down_solid, size: 15),
//       ],
//     );

//     final bottomBar = InkWell(
//       onTap: controller.switchAccounts,
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Card(
//           elevation: 2.0,
//           child: Padding(
//             padding: const EdgeInsets.all(15),
//             child: bottomContent,
//           ),
//         ),
//       ),
//     );

//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: appBar,
//         bottomNavigationBar: bottomBar,
//         body: content,
//       ),
//     );
//   }
// }
