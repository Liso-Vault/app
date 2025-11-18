// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:liso/features/groups/groups.controller.dart';

import 'metadata/metadata.hive.dart';

part 'group.hive.g.dart';

@HiveType(typeId: 10)
class HiveLisoGroup extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String iconUrl;
  @HiveField(2)
  String name;
  @HiveField(3)
  String description;
  @HiveField(4)
  bool reserved;
  @HiveField(6)
  bool? deleted;
  @HiveField(5)
  HiveMetadata? metadata;

  HiveLisoGroup({
    required this.id,
    this.iconUrl = '',
    required this.name,
    this.description = '',
    this.reserved = false,
    this.deleted = false,
    required this.metadata,
  });

  factory HiveLisoGroup.fromJson(Map<String, dynamic> json) => HiveLisoGroup(
        id: json["id"],
        iconUrl: json["icon_url"],
        name: json["name"],
        description: json["description"],
        reserved: json["reserved"],
        deleted: json["deleted"] ?? false,
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
      "reserved": reserved,
      "deleted": deleted ?? false,
      "metadata": metadata?.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, name, description];

  // GETTERS
  String get reservedName => isReserved ? id.tr : name;

  String get reservedDescription => isReserved ? '${id}_desc'.tr : description;

  bool get isReserved => GroupsController.to.reservedIds.contains(id);
}
