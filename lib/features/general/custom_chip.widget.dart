import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final Text label;
  final EdgeInsets padding;

  const CustomChip({
    Key? key,
    required this.label,
    this.padding = const EdgeInsets.symmetric(
      vertical: 1,
      horizontal: 6,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (label.data!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          child: label,
          color: Colors.grey.shade800,
          padding: padding,
        ),
      ),
    );
  }
}