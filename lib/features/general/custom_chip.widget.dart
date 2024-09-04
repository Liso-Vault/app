import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomChip extends StatelessWidget {
  final Text label;
  final Color? color;
  final Widget? icon;
  final EdgeInsets padding;

  const CustomChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.padding = const EdgeInsets.symmetric(
      vertical: 1,
      horizontal: 6,
    ),
  });

  @override
  Widget build(BuildContext context) {
    if (label.data!.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: color ?? Get.theme.secondaryHeaderColor,
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 5)],
            label,
          ],
        ),
      ),
    );
  }
}
