import 'package:flutter/material.dart';

class TitledDivider extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  const TitledDivider({
    Key? key,
    required this.title,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
