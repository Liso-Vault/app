import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../resources/resources.dart';

class RemoteImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final Alignment alignment;

  const RemoteImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final placeholder = Image.asset(
      Images.placeholder,
      fit: BoxFit.cover,
      width: width,
      height: height,
    );

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      placeholder: (context, _) => placeholder,
      alignment: alignment,
      errorWidget: (_, str, dyn) => Placeholder(
        fallbackHeight: height ?? 50,
        fallbackWidth: width ?? 50,
      ),
    );
  }
}