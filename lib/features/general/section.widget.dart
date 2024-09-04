import 'package:flutter/material.dart';
import 'package:liso/core/utils/globals.dart';

class Section extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final CrossAxisAlignment alignment;
  final EdgeInsets padding;

  const Section({
    super.key,
    required this.text,
    this.fontSize = 10,
    this.color,
    this.alignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? themeColor;

    return Padding(
      padding: padding,
      child: Opacity(
        opacity: 0.6,
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Text(
              text,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: fontSize, color: color),
            ),
            Divider(height: 5, color: color),
          ],
        ),
      ),
    );
  }
}
