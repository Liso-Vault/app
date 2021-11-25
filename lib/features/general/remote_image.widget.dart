// import 'package:flutter/material.dart';

// class RemoteImageCached extends StatelessWidget {
//   final String url;
//   final double size, width, height;

//   const RemoteImageCached({
//     this.url,
//     this.size,
//     this.width,
//     this.height,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final placeholder = Image.asset(
//       kAssetPlaceHolderImage,
//       fit: BoxFit.cover,
//       height: size ?? height,
//       width: size ?? width,
//     );

//     return CachedNetworkImage(
//       imageUrl: url,
//       height: size ?? height,
//       width: size ?? width,
//       placeholder: (context, _) => placeholder,
//       errorWidget: (_, str, dyn) => Placeholder(
//         fallbackHeight: size ?? height ?? 50,
//         fallbackWidth: size ?? width ?? 50,
//       ),
//     );
//   }
// }
