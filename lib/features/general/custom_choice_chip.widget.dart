import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool)? onSelected;

  const CustomChoiceChip({
    Key? key,
    required this.label,
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

    return Theme(
      data: Get.theme.copyWith(
        chipTheme: Get.theme.chipTheme.copyWith(
          selectedColor: Colors.amber.withOpacity(0.5),
          backgroundColor: Colors.amber.withOpacity(0.2),
          checkmarkColor: textColor,
        ),
      ),
      child: FilterChip(
        label: Text(label, style: TextStyle(color: textColor)),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}
