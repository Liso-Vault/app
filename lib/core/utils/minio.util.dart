import 'package:minio/models.dart';

class MinioUtil {
  static Object objectFromJson(Map<String, dynamic> json) => Object(
        json['e_tag'],
        json['key'],
        DateTime.parse(json['last_modified']),
        ownerFromJson(json['owner']),
        json['size'],
        json['storage_class'],
      );

  static Map<String, dynamic> objectToJson(Object? object) {
    return {
      "e_tag": object?.eTag?.replaceAll('"', ''),
      "path": object?.key,
      "last_modified": object?.lastModified?.toIso8601String(),
      "owner": ownerToJson(object?.owner),
      "size": object?.size,
      "storage_class": object?.storageClass,
    };
  }

  static Owner ownerFromJson(Map<String, dynamic> json) => Owner(
        json['display_name'],
        json['id'],
      );

  static Map<String, dynamic> ownerToJson(Owner? owner) {
    return {
      "display_name": owner?.displayName,
      "id": owner?.iD,
    };
  }
}
