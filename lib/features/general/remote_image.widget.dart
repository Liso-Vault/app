import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../resources/resources.dart';

class RemoteImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final Alignment alignment;
  final Image? placeholder;

  const RemoteImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      placeholder: (context, _) =>
          placeholder ??
          Image.asset(
            Images.placeholder,
            fit: BoxFit.cover,
            width: width,
            height: height,
          ),
      alignment: alignment,
      errorWidget: (_, str, dyn) => Placeholder(
        fallbackHeight: height ?? 50,
        fallbackWidth: width ?? 50,
      ),
    );
  }
}

class DiceBearAvatar extends StatelessWidget {
  final String sprites;
  final String seed;
  final double size;

  const DiceBearAvatar({
    Key? key,
    this.sprites = 'big-smile',
    required this.seed,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final placeholder = ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: Image.asset(
        Images.placeholder,
        fit: BoxFit.cover,
        height: size,
        width: size,
      ),
    );

    return SvgPicture.network(
      'https://avatars.dicebear.com/api/$sprites/$seed.svg?size=$size&radius=50',
      height: size,
      width: size,
      placeholderBuilder: (_) => placeholder,
    );
  }
}
