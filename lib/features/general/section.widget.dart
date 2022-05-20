import 'package:flutter/material.dart';
import 'package:liso/core/utils/globals.dart';

class Section extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final CrossAxisAlignment alignment;

  const Section({
    Key? key,
    required this.text,
    this.fontSize = 10,
    this.color,
    this.alignment = CrossAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? themeColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
