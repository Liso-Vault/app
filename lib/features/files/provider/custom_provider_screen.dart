// import 'package:app_core/pages/routes.dart';
// import 'package:app_core/utils/utils.dart';
// import 'package:app_core/widgets/appbar_leading.widget.dart';
// import 'package:console_mixin/console_mixin.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:liso/features/files/provider/custom_provider_screen.controller.dart';

// import '../../../core/persistence/secret_persistence.builder.dart';
// import '../../../core/utils/globals.dart';

// class CustomSyncProviderScreen extends StatelessWidget with ConsoleMixin {
//   const CustomSyncProviderScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(CustomSyncProviderScreenController());

//     final content = SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Form(
//         key: controller.formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               controller: controller.endpointController,
//               validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               decoration: const InputDecoration(
//                 labelText: 'Endpoint',
//                 hintText: 's3.filebase.com',
//               ),
//             ),
//             const SizedBox(height: 15),
//             TextFormField(
//               controller: controller.accessKeyController,
//               validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               decoration: const InputDecoration(
//                 labelText: 'Access Key',
//               ),
//             ),
//             const SizedBox(height: 15),
//             TextFormField(
//               controller: controller.secretKeyController,
//               validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               decoration: const InputDecoration(
//                 labelText: 'Secret Key',
//               ),
//             ),
//             const SizedBox(height: 15),
//             TextFormField(
//               controller: controller.bucketController,
//               validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               decoration: const InputDecoration(
//                 labelText: 'Bucket',
//               ),
//             ),
//             const SizedBox(height: 15),
//             TextFormField(
//               controller: controller.portController,
//               // TODO: validator
//               inputFormatters: [
//                 inputFormatterRestrictSpaces,
//                 inputFormatterNumericOnly,
//               ],
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Port',
//                 hintText: '8080',
//               ),
//             ),
//             const SizedBox(height: 15),
//             TextFormField(
//               controller: controller.regionController,
//               // TODO: validator
//               decoration: const InputDecoration(
//                 labelText: 'Region',
//               ),
//             ),
//             const SizedBox(height: 15),
//             TextFormField(
//               controller: controller.sessionTokenController,
//               // TODO: validator
//               decoration: const InputDecoration(
//                 labelText: 'Session Token',
//               ),
//             ),
//             const Divider(),
//             SecretPersistenceBuilder(
//               builder: (p, context) => SwitchListTile(
//                 title: const Text('Enable Trace'),
//                 value: p.s3EnableTrace.val,
//                 onChanged: (value) => p.s3EnableTrace.val = value,
//                 // contentPadding: EdgeInsets.zero,
//               ),
//             ),
//             const Divider(),
//             SecretPersistenceBuilder(
//               builder: (p, context) => SwitchListTile(
//                 title: const Text('Use SSL'),
//                 value: p.s3UseSsl.val,
//                 onChanged: (value) => p.s3UseSsl.val = value,
//                 // contentPadding: EdgeInsets.zero,
//               ),
//             ),
//             const Divider(),
//           ],
//         ),
//       ),
//     );

//     final actions = [
//       TextButton(
//         onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
//         child: const Text('Help ?'),
//       ),
//       Obx(
//         () => controller.busy.value
//             ? const Padding(
//                 padding: EdgeInsets.all(10),
//                 child: Center(
//                   child: SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(),
//                   ),
//                 ),
//               )
//             : IconButton(
//                 onPressed: controller.testConnection,
//                 icon: const Icon(Icons.check),
//               ),
//       ),
//       const SizedBox(width: 10),
//     ];

//     final appBar = AppBar(
//       title: const Text('S3 Configuration'),
//       leading: const AppBarLeadingButton(),
//       actions: actions,
//     );

//     return Scaffold(
//       appBar: appBar,
//       body: content,
//     );
//   }
// }
