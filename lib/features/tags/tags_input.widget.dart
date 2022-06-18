import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/tags/tags_input.controller.dart';

class TagsInput extends StatelessWidget {
  final String label;
  final bool enabled;
  final TagsInputController controller;

  const TagsInput({
    Key? key,
    required this.label,
    required this.controller,
    this.enabled = true,
  }) : super(key: key);

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
            ...controller.data
                .map(
                  (e) => Chip(
                    label: Text(e),
                    onDeleted: enabled ? () => controller.data.remove(e) : null,
                  ),
                )
                .toList(),
            if (enabled) ...[
              ActionChip(
                label: const Icon(Iconsax.add_circle5, size: 20),
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
