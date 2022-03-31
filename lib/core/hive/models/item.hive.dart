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
  String type;
  @HiveField(1)
  Uint8List icon;
  @HiveField(2)
  String title;
  @HiveField(3)
  List<HiveLisoField> fields;
  @HiveField(4)
  List<String> tags;
  @HiveField(5)
  HiveMetadata metadata;

  HiveLisoItem({
    required this.type,
    required this.icon,
    required this.title,
    required this.fields,
    required this.tags,
    required this.metadata,
  });

  factory HiveLisoItem.fromJson(Map<String, dynamic> json) => HiveLisoItem(
        type: json["type"],
        icon: json["icon"],
        title: json["title"],
        fields: json["fields"],
        tags: json["tags"],
        metadata: HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "icon": icon,
      "title": title,
      "fields": List<dynamic>.from(fields.map((x) => x.toJson())),
      "tags": tags,
      "metadata": metadata.toJson(),
    };
  }

  List<Widget> get widgets => fields.map((e) => e.widget).toList();

  String get subTitle {
    final _type = LisoItemType.values.byName(type);

    if (_type == LisoItemType.cryptoWallet) {
      return 'Crypto Sub';
    }

    return 'Sub Title Placeholder';
  }
}
