import 'package:flutter/material.dart';

class SegmentedControlItem extends StatelessWidget {
  final String text;
  final IconData iconData;

  const SegmentedControlItem({
    Key? key,
    required this.text,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }
}
