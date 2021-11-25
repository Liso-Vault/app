// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../core/controllers/global.controller.dart';

// class SheetPageOptionButton extends StatelessWidget {
//   final Widget icon;
//   final String text;
//   final VoidCallback onTap;

//   const SheetPageOptionButton({
//     @required this.icon,
//     @required this.text,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final _content = Padding(
//       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
//       child: Column(
//         children: <Widget>[
//           icon,
//           const SizedBox(height: 10),
//           Text(
//             text,
//             style: const TextStyle(fontSize: 12),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );

//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         child: Opacity(
//           opacity: onTap != null ? 1.0 : 0.5,
//           child: Obx(
//             () => Card(
//               color: GlobalController.to.darkMode()
//                   ? Colors.grey.withOpacity(0.1)
//                   : Colors.white,
//               elevation: GlobalController.to.darkMode() ? 1.0 : 3.0,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//               child: _content,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
