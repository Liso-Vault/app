import 'package:hive/hive.dart';

import '../../liso/liso_field.model.dart';
import 'metadata.hive.dart';

// part 'item.hive.g.dart';

@HiveType(typeId: 1)
class HiveVaultItem extends HiveObject {
  @HiveField(0)
  List<LisoField> fields;
  @HiveField(1)
  HiveMetadata metadata;

  HiveVaultItem({
    required this.fields,
    required this.metadata,
  });

  factory HiveVaultItem.fromJson(Map<String, dynamic> json) => HiveVaultItem(
        fields: json["fields"],
        metadata: HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "fields": List<dynamic>.from(fields.map((x) => x.toJson())),
      "metadata": metadata.toJson(),
    };
  }
}
