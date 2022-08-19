import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/items/item.tile.dart';

import '../../core/hive/models/item.hive.dart';

class ItemsSearchDelegate extends SearchDelegate with ConsoleMixin {
  final bool joinedVaultItem;
  final List<HiveLisoItem> items;
  ItemsSearchDelegate(this.items, {this.joinedVaultItem = false});

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
      const SizedBox(width: 10),
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
      return const Center(child: Text("Search items"));
    }

    final filteredItems = items.where((e) {
      if (e.deleted) return false;

      final query_ = query.toLowerCase();

      if (e.appIds != null &&
          e.appIds!.join(' ').toLowerCase().contains(query_)) {
        return true;
      }

      if (e.uris != null && e.uris!.contains(Uri.tryParse(query_))) {
        return true;
      }

      if (e.title.toLowerCase().contains(query_)) {
        return true;
      }

      if (e.subTitle.toLowerCase().contains(query_)) {
        return true;
      }

      if (e.tags.join(' ').toLowerCase().contains(query_)) {
        return true;
      }

      // TODO: this can be expensive in performance
      // search deeply through field values
      for (var e in e.fields) {
        if (e.data.value!.toLowerCase().contains(query_)) {
          return true;
        }
      }

      return false;
    }).toList();

    if (filteredItems.isEmpty) {
      return CenteredPlaceholder(
        iconData: Iconsax.search_normal,
        message: 'no_results'.tr,
      );
    }

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) => ItemTile(
        filteredItems[index],
        searchMode: true,
        joinedVaultItem: joinedVaultItem,
      ),
    );
  }

  void reload(BuildContext context) {
    process();
    showResults(context);
    showSuggestions(context);
  }
}
