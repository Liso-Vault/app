import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

import 'field.hive.dart';
import 'metadata/metadata.hive.dart';

part 'item.hive.g.dart';

@HiveType(typeId: 1)
class HiveLisoItem extends HiveObject {
  @HiveField(0)
  String icon;
  @HiveField(1)
  String title;
  @HiveField(2)
  List<HiveLisoField> fields;
  @HiveField(3)
  List<String> tags;
  @HiveField(4)
  HiveMetadata metadata;

  HiveLisoItem({
    required this.icon,
    required this.title,
    required this.fields,
    required this.tags,
    required this.metadata,
  });

  factory HiveLisoItem.fromJson(Map<String, dynamic> json) => HiveLisoItem(
        icon: json["icon"],
        title: json["title"],
        fields: json["fields"],
        tags: json["tags"],
        metadata: HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "icon": icon,
      "title": title,
      "fields": List<dynamic>.from(fields.map((x) => x.toJson())),
      "tags": tags,
      "metadata": metadata.toJson(),
    };
  }

  List<Widget> get widgets => fields.map((e) => e.widget).toList();

  String get subTitle {
    return 'Sub Title Placeholder';
  }
}
