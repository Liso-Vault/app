// import 'package:liso/core/controllers/persistence.controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:supercharged_dart/supercharged_dart.dart';

// class CustomTooltip extends StatelessWidget {
//   final String id;
//   final String message;
//   final Widget child;

//   const CustomTooltip({
//     @required this.id,
//     @required this.message,
//     @required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final PersistenceController persistence = Get.find();
//     // if already shown tooltip, don't show again
//     if (persistence.box.read(id) ?? false) return child;

//     final key = GlobalKey();

//     final tooltip = Tooltip(
//       key: key,
//       message: message,
//       child: child,
//       padding: const EdgeInsets.all(10),
//     );

//     Future.delayed(1.seconds).then(
//       (_) {
//         final dynamic tooltipState = key.currentState;
//         tooltipState.ensureTooltipVisible();
//         persistence.box.write(id, true);
//       },
//     );

//     return tooltip;
//   }
// }
