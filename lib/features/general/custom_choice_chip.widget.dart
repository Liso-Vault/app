import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomChoiceChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final Function(bool)? onSelected;

  const CustomChoiceChip({
    Key? key,
    required this.label,
    this.color,
    this.selected = false,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? textColor;

    if (Get.isDarkMode && selected) {
      textColor = Colors.white;
    } else if (!Get.isDarkMode && selected) {
      textColor = Colors.black;
    }

    final chip = FilterChip(
      label: Text(label, style: TextStyle(color: textColor)),
      selected: selected,
      onSelected: onSelected,
      checkmarkColor: textColor,
    );

    if (color == null) return chip;

    return Theme(
      data: Get.theme.copyWith(
        chipTheme: Get.theme.chipTheme.copyWith(
          selectedColor: color!.withOpacity(0.5),
          backgroundColor: color!.withOpacity(0.2),
          checkmarkColor: textColor,
        ),
      ),
      child: chip,
    );
  }
}
