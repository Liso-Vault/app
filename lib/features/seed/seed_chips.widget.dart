import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';

import '../general/custom_chip.widget.dart';

class SeedChips extends StatelessWidget {
  final List<String> seeds;

  const SeedChips({super.key, required this.seeds});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: isSmallScreen ? 5 : 5,
      runSpacing: isSmallScreen ? 5 : 10,
      alignment: WrapAlignment.center,
      children: seeds
          .asMap()
          .entries
          .map(
            (e) => CustomChip(
              label: Text(
                '${e.key + 1}. ${e.value}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 18,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
