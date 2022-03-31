import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/utils/globals.dart';

import 'field.hive.dart';
import 'metadata/metadata.hive.dart';

part 'item.hive.g.dart';

@HiveType(typeId: 1)
class HiveLisoItem extends HiveObject {
  @HiveField(0)
  String category;
  @HiveField(1)
  Uint8List icon;
  @HiveField(2)
  String title;
  @HiveField(3)
  List<HiveLisoField> fields;
  @HiveField(4)
  bool favorite;
  @HiveField(5)
  List<String> tags;
  @HiveField(6)
  HiveMetadata metadata;

  HiveLisoItem({
    required this.category,
    required this.icon,
    required this.title,
    required this.fields,
    this.favorite = false,
    this.tags = const [],
    required this.metadata,
  });

  factory HiveLisoItem.fromJson(Map<String, dynamic> json) => HiveLisoItem(
        category: json["category"],
        icon: json["icon"],
        title: json["title"],
        fields: json["fields"],
        favorite: json["favorite"],
        tags: json["tags"],
        metadata: HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "category": category,
      "icon": icon,
      "title": title,
      "fields": List<dynamic>.from(fields.map((x) => x.toJson())),
      "favorite": favorite,
      "tags": tags,
      "metadata": metadata.toJson(),
    };
  }

  List<Widget> get widgets => fields.map((e) => e.widget).toList();

  String get subTitle {
    final _category = LisoItemCategory.values.byName(category);

    String value;

    switch (_category) {
      case LisoItemCategory.cryptoWallet:
        value = 'Crypto Sub';
        break;
      default:
        value = '';
    }

    return value;
  }
}
