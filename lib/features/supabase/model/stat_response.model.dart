import 'package:app_core/supabase/model/error.model.dart';

import 'object.model.dart';

class StatObjectResponse {
  StatObjectResponse({
    this.status = 0,
    this.data = const S3Object(),
    this.errors = const [],
  });

  final int status;
  final S3Object data;
  final List<SupabaseFunctionError> errors;

  factory StatObjectResponse.fromJson(Map<String, dynamic> json) =>
      StatObjectResponse(
        status: json["status"],
        data: S3Object.fromJson(json["data"]),
        errors: List<SupabaseFunctionError>.from(
            json["errors"].map((x) => SupabaseFunctionError.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "errors": List<dynamic>.from(errors.map((x) => x.toJson())),
      };
}
