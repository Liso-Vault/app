import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

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

  HiveLisoGroup({
    required this.id,
    this.iconUrl = '',
    required this.name,
    this.description = '',
  });

  factory HiveLisoGroup.fromJson(Map<String, dynamic> json) => HiveLisoGroup(
        id: json["id"],
        iconUrl: json["icon_url"],
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "icon_url": iconUrl,
      "name": name,
      "description": description,
    };
  }

  @override
  List<Object?> get props => [id, name, description];

  // GETTERS
  String get reservedName => id.tr;
  String get reservedDescription => '${id}_desc'.tr;
}
