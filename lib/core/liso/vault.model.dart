import 'dart:convert';

import '../hive/models/category.hive.dart';
import '../hive/models/group.hive.dart';
import '../hive/models/item.hive.dart';
import '../hive/models/metadata/metadata.hive.dart';

class LisoVault {
  const LisoVault({
    this.groups = const [],
    this.categories = const [],
    this.items = const [],
    this.persistence = const {},
    this.version = 0,
    this.metadata,
  });

  final List<HiveLisoGroup> groups;
  final List<HiveLisoCategory>? categories;
  final List<HiveLisoItem> items;
  final Map<dynamic, dynamic> persistence;
  final int version;
  final HiveMetadata? metadata;

  factory LisoVault.fromJson(Map<String, dynamic> json) => LisoVault(
        groups: List<HiveLisoGroup>.from(
          json["groups"].map((x) => HiveLisoGroup.fromJson(x)),
        ),
        categories: json["categories"] != null
            ? List<HiveLisoCategory>.from(
                json["categories"].map((x) => HiveLisoCategory.fromJson(x)),
              )
            : [],
        items: List<HiveLisoItem>.from(
          json["items"].map((x) => HiveLisoItem.fromJson(x)),
        ),
        persistence: json["persistence"],
        version: json["version"],
        metadata: HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "groups": List<dynamic>.from(groups.map((e) => e.toJson())),
        "categories": List<dynamic>.from(categories!.map((e) => e.toJson())),
        "items": List<dynamic>.from(items.map((e) => e.toJson())),
        "persistence": persistence,
        "version": version,
        "metadata": metadata?.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());
}
