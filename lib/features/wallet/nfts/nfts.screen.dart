// import 'package:app_core/widgets/busy_indicator.widget.dart';
// import 'package:app_core/widgets/remote_image.widget.dart';
// import 'package:console_mixin/console_mixin.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:icons_plus/icons_plus.dart';

// import 'package:liso/features/general/keep_alive.widget.dart';

// import '../../general/centered_placeholder.widget.dart';
// import 'nfts_screen.controller.dart';

// class NFTsScreen extends StatelessWidget with ConsoleMixin {
//   const NFTsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(NFTsScreenController());

//     final listView = Obx(
//       () => ListView.builder(
//         itemCount: controller.data.length,
//         shrinkWrap: true,
//         controller: ScrollController(),
//         itemBuilder: (context, index) {
//           final data = controller.data[index];
//           return ListTile(
//             leading: RemoteImage(
//               url: data.metadata!.image!,
//               width: 50,
//               height: 50,
//             ),
//             title: Text(data.title!),
//             subtitle: Text('${data.description}'),
//           );
//         },
//       ),
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
