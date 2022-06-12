import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../utils/globals.dart';
import 'metadata/metadata.hive.dart';

part 'category.hive.g.dart';

@HiveType(typeId: 11)
class HiveLisoCategory extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String iconUrl;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String description;
  @HiveField(4)
  String significant;
  @HiveField(5)
  List<HiveLisoField> fields;
  @HiveField(6)
  bool reserved;
  @HiveField(7)
  HiveMetadata? metadata;

  HiveLisoCategory({
    required this.id,
    this.iconUrl = '',
    required this.name,
    this.description = '',
    this.significant = '',
    this.fields = const [],
    this.reserved = false,
    required this.metadata,
  });

  factory HiveLisoCategory.fromJson(Map<String, dynamic> json) =>
      HiveLisoCategory(
        id: json["id"],
        iconUrl: json["icon_url"],
        name: json["name"],
        description: json["description"],
        significant: json["significant"],
        fields: List<HiveLisoField>.from(
          json["fields"].map((x) => HiveLisoField.fromJson(x)),
        ),
        reserved: json["reserved"],
        metadata: json["metadata"] == null
            ? null
            : HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "icon_url": iconUrl,
      "name": name,
      "description": description,
      "significant": significant,
      "fields": List<dynamic>.from(fields.map((x) => x.toJson())),
      "reserved": reserved,
      "metadata": metadata?.toJson(),
    };
  }

  @override
  List<Object?> get props =>
      [id, name, description, significant, fields, reserved];

  // GETTERS
  String get reservedName => reservedCategories.contains(id) ? id.tr : name;
  String get reservedDescription =>
      reservedCategories.contains(id) ? '${id}_desc'.tr : description;

  bool get isReserved => reservedCategories.contains(id);
}