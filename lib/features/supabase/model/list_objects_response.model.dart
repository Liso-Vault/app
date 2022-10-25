import 'package:app_core/supabase/model/error.model.dart';

import 'object.model.dart';

class ListObjectsResponse {
  const ListObjectsResponse({
    this.status = 0,
    this.data = const ListObjectsData(),
    this.errors = const [],
  });

  final int status;
  final ListObjectsData data;
  final List<SupabaseFunctionError> errors;

  factory ListObjectsResponse.fromJson(Map<String, dynamic> json) =>
      ListObjectsResponse(
        status: json["status"],
        data: ListObjectsData.fromJson(json["data"]),
        errors: List<SupabaseFunctionError>.from(
            json["errors"].map((x) => SupabaseFunctionError.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "errors": List<dynamic>.from(errors.map((x) => x.toJson())),
      };
}

class ListObjectsData {
  const ListObjectsData({
    this.count = 0,
    this.size = 0,
    this.objects = const [],
  });

  final int count;
  final int size;
  final List<S3Object> objects;

  factory ListObjectsData.fromJson(Map<String, dynamic> json) =>
      ListObjectsData(
        count: json["count"],
        size: json["size"],
        objects: List<S3Object>.from(
            json["objects"].map((x) => S3Object.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "size": size,
        "objects": List<dynamic>.from(objects.map((x) => x.toJson())),
      };
}
