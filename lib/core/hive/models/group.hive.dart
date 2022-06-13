import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/features/groups/groups.controller.dart';

import 'metadata/metadata.hive.dart';

part 'group.hive.g.dart';

@HiveType(typeId: 10)
class HiveLisoGroup extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String iconUrl;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String description;
  @HiveField(4)
  bool reserved;
  @HiveField(5)
  HiveMetadata? metadata;

  HiveLisoGroup({
    required this.id,
    this.iconUrl = '',
    required this.name,
    this.description = '',
    this.reserved = false,
    required this.metadata,
  });

  factory HiveLisoGroup.fromJson(Map<String, dynamic> json) => HiveLisoGroup(
        id: json["id"],
        iconUrl: json["icon_url"],
        name: json["name"],
        description: json["description"],
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
      "reserved": reserved,
      "metadata": metadata?.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, name, description];

  // GETTERS
  String get reservedName =>
      GroupsController.to.reservedIds.contains(id) ? id.tr : name;

  String get reservedDescription => GroupsController.to.reservedIds.contains(id)
      ? '${id}_desc'.tr
      : description;

  bool get isReserved => GroupsController.to.reservedIds.contains(id);
}
