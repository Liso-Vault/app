import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DiceBearAvatar extends StatelessWidget {
  final String sprites;
  final String seed;
  final double size;

  const DiceBearAvatar({
    Key? key,
    this.sprites = 'pixel-art',
    required this.seed,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final placeholder = ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: SizedBox(height: size, width: size),
    );

    return SvgPicture.network(
      'https://avatars.dicebear.com/api/$sprites/$seed.svg?size=$size&radius=50',
      height: size,
      width: size,
      placeholderBuilder: (_) => placeholder,
    );
  }
}
