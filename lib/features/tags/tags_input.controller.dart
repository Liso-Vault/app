import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../items/items.service.dart';

class TagsInputController extends GetxController {
  // VARIABLES
  final queryController = TextEditingController();

  // PROPERTIES
  final data = <String>[].obs;
  final suggestions = <String>[].obs;

  // FUNCTIONS
  void add() async {
    final formKey = GlobalKey<FormState>();

    List<String> query(String query) {
      final usedTags = ItemsService.to.data
          .map((e) => e.tags
              .where((tag) => tag.isNotEmpty && !data.contains(tag))
              .toList())
          .toSet();

      // include query as a suggested tag
      final Set<String> tags = {query};

      if (usedTags.isNotEmpty) {
        tags.addAll(usedTags.reduce((a, b) => a + b).toSet());
      }

      final filteredTags = tags.where(
        (tag) =>
            tag.toLowerCase().contains(query.toLowerCase()) &&
            !data.contains(tag) &&
            tag.isNotEmpty,
      );

      return filteredTags.toList();
    }

    void add(String tag) {
      data.add(tag);
      queryController.clear();
      suggestions.value = query('');
    }

    final textField = TextFormField(
      controller: queryController,
      autofocus: true,
      decoration: const InputDecoration(
        labelText: 'Add a tag',
        hintText: 'Add or query some tags',
      ),
      onChanged: (value) => suggestions.value = query(value),
      validator: (value) =>
          value!.length >= 3 ? null : 'Must be at least 3 letter word',
      onFieldSubmitted: (tag) {
        if (!formKey.currentState!.validate()) return;
        add(tag);
      },
    );

    final listView = Expanded(
      child: Obx(
        () => ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final tag = suggestions[index];

            return ListTile(
              title: Text(tag),
              onTap: () => add(tag),
            );
          },
        ),
      ),
    );

    final tags = Obx(
      () => Wrap(
        spacing: 5,
        runSpacing: 5,
        children: data
            .map(
              (e) => Chip(
                label: Text(e),
                onDeleted: () => data.remove(e),
              ),
            )
            .toList(),
      ),
    );

    final content = Container(
      padding: const EdgeInsets.all(20),
      color: Get.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Tags', style: TextStyle(color: Colors.grey)),
              ),
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.check),
              ),
              IconButton(
                onPressed: Get.back,
                icon: const Icon(LineAwesome.times_solid),
              ),
            ],
          ),
          const SizedBox(height: 5),
          tags,
          const Divider(),
          Form(
            key: formKey,
            child: textField,
          ),
          const SizedBox(height: 10),
          const Text('Suggestions', style: TextStyle(color: Colors.grey)),
          listView,
        ],
      ),
    );

    // pre-load suggestions
    suggestions.value = query('');

    if (isSmallScreen) {
      await Get.bottomSheet(content);
    } else {
      Get.dialog(Dialog(
        child: SizedBox(
          height: 500,
          width: 500,
          child: content,
        ),
      ));
    }
  }
}
