// import 'package:app_core/globals.dart';
// import 'package:app_core/persistence/persistence_builder.widget.dart';
// import 'package:app_core/widgets/busy_indicator.widget.dart';
// import 'package:console_mixin/console_mixin.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:icons_plus/icons_plus.dart';

// import 'package:liso/features/general/keep_alive.widget.dart';

// import '../../../core/persistence/persistence.dart';
// import '../../../resources/resources.dart';
// import '../../general/centered_placeholder.widget.dart';
// import '../wallet.service.dart';
// import 'assets_screen.controller.dart';

// class AssetsScreen extends StatelessWidget with ConsoleMixin {
//   const AssetsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AssetsScreenController());
//     final wallet = Get.find<WalletService>();

//     final listView = PersistenceBuilder(
//       builder: (p, context) {
//         final liso =
//             currencyFormatter.format(AppPersistence.to.lastLisoBalance.val);
//         final lisoUsd = currencyFormatter.format(wallet.lisoUsdBalance);

//         final matic =
//             currencyFormatter.format(AppPersistence.to.lastMaticBalance.val);
//         final maticUsd = currencyFormatter.format(wallet.maticUsdBalance);

//         return ListView(
//           shrinkWrap: true,
//           controller: ScrollController(),
//           children: [
//             ListTile(
//               leading: Image.asset(Images.logo, height: 18),
//               trailing: const Icon(Iconsax.arrow_right_3_outline),
//               title: Text('$liso LISO'),
//               subtitle: Text('\$$lisoUsd'),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: Image.asset(Images.polygon, height: 18),
//               trailing: const Icon(Iconsax.arrow_right_3_outline),
//               title: Text('$matic MATIC'),
//               subtitle: Text('\$$maticUsd'),
//               onTap: () {},
//             ),
//           ],
//         );
//       },
//     );

//     final content = controller.obx(
//       (_) => listView,
//       onLoading: const BusyIndicator(),
//       onEmpty: CenteredPlaceholder(
//         iconData: Iconsax.image_outline,
//         message: 'No NFTs',
//         child: TextButton.icon(
//           icon: const Icon(Iconsax.refresh_outline),
//           onPressed: controller.load,
//           label: Text(
//             'refresh'.tr,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );

//     return KeepAliveWrapper(child: content);
//   }
// }
