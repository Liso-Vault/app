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
    Color? color;

    if (Get.isDarkMode && selected) {
      color = Colors.white;
    } else if (!Get.isDarkMode && selected) {
      color = Colors.black;
    }

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      selected: selected,
      avatar: selected ? Icon(Icons.check, color: color) : null,
      onSelected: onSelected,
    );
  }
}
