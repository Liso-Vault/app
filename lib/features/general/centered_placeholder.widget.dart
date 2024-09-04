import 'package:flutter/material.dart';
import 'package:liso/core/utils/styles.dart';

class CenteredPlaceholder extends StatelessWidget {
  final IconData iconData;
  final String message;
  final Widget? child;

  const CenteredPlaceholder({
    super.key,
    required this.iconData,
    required this.message,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: Styles.containerConstraints,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, size: 100, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (child != null) ...[
                const SizedBox(height: 25),
                child!,
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// class CenteredPlaceholder2 extends StatelessWidget {
//   final Widget image;
//   final Widget text;
//   final Widget? child;

//   const CenteredPlaceholder2({
//     Key? key,
//     required this.image,
//     required this.text,
//     this.child,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         constraints: Styles.containerConstraints,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               image,
//               const SizedBox(height: 20),
//               text,
//               if (child != null) ...[
//                 const SizedBox(height: 20),
//                 child!,
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
