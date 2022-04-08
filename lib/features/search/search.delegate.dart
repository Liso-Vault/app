import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/item/item.tile.dart';
import 'package:liso/features/main/main_screen.controller.dart';

class ItemsSearchDelegate extends SearchDelegate with ConsoleMixin {
  @override
  // TODO: implement searchFieldLabel
  String? get searchFieldLabel => 'search_by_title'.tr;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => process();

  @override
  Widget buildSuggestions(BuildContext context) => process();

  Widget process() {
    if (query.isEmpty) {
      return const Center(child: Text("Search items by title."));
    }

    final items = HiveManager.items!.values
        .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    console.info('search result: ${items.length}');

    final listView = ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemTile(items[index], searchMode: true),
    );

    return GetPlatform.isMobile
        ? listView
        : MouseRegion(
            child: listView,
            onHover: (event) =>
                MainScreenController.to.lastMousePosition = event.position,
          );
  }

  void reload(BuildContext context) {
    process();
    showResults(context);
    showSuggestions(context);
  }
}
