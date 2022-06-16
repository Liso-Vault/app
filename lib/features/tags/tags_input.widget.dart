import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/features/tags/tags_input.controller.dart';

class TagsInput extends StatelessWidget {
  final String label;
  final TagsInputController controller;

  const TagsInput({
    Key? key,
    required this.label,
    required this.controller,
  }) : super(key: key);

  List<String> get value => controller.data;

  @override
  Widget build(BuildContext context) {
    final tags = Obx(
      () => Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          ...controller.data
              .map(
                (e) => Chip(
                  label: Text(e),
                  onDeleted: () => controller.data.remove(e),
                ),
              )
              .toList(),
          ActionChip(
            label: const Icon(Iconsax.add_circle5, size: 20),
            onPressed: controller.add,
          )
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        tags,
      ],
    );
  }
}
