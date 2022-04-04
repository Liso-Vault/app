import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final Text label;
  const CustomChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          child: label,
          color: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(
            vertical: 1,
            horizontal: 4,
          ),
        ),
      ),
    );
  }
}
