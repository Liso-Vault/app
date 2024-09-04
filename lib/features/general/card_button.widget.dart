import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Function()? onPressed;

  const CardButton({
    super.key,
    required this.text,
    required this.iconData,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
      ),
      child: Column(
        children: [
          Icon(iconData, size: 30),
          const SizedBox(height: 5),
          Text(text),
        ],
      ),
    );
  }
}
