import 'package:flutter/material.dart';

import '../../core/utils/utils.dart';
import '../general/custom_chip.widget.dart';

class SeedChips extends StatelessWidget {
  final List<String> seeds;

  const SeedChips({Key? key, required this.seeds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Utils.isSmallScreen ? 5 : 5,
      runSpacing: Utils.isSmallScreen ? 5 : 10,
      alignment: WrapAlignment.center,
      children: seeds
          .asMap()
          .entries
          .map(
            (e) => CustomChip(
              label: Text(
                '${e.key + 1}. ${e.value}',
                style: TextStyle(
                  fontSize: Utils.isSmallScreen ? 15 : 18,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
