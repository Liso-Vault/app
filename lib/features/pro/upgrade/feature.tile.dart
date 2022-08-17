import 'package:flutter/material.dart';
import 'package:liso/core/utils/globals.dart';

class FeatureTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Widget trailing;

  const FeatureTile({
    Key? key,
    required this.iconData,
    required this.title,
    required this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, color: proColor),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing,
        ],
      ),
    );
  }
}
