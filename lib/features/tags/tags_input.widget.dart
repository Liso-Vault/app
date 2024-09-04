import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/tags/tags_input.controller.dart';

class TagsInput extends StatelessWidget {
  final String label;
  final bool enabled;
  final TagsInputController controller;

  const TagsInput({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
  });

  List<String> get value => controller.data;

  @override
  Widget build(BuildContext context) {
    final tags = Obx(
      () => Opacity(
        opacity: enabled ? 1.0 : 0.6,
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            ...controller.data.map(
              (e) => Chip(
                label: Text(e),
                onDeleted: enabled ? () => controller.data.remove(e) : null,
              ),
            ),
            if (enabled) ...[
              ActionChip(
                label: const Icon(Iconsax.add_circle_outline, size: 20),
                onPressed: controller.add,
              ),
            ],
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: themeColor, fontSize: 12)),
        const SizedBox(height: 5),
        tags,
      ],
    );
  }
}
