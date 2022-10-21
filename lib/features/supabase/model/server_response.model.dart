import 'error.model.dart';

class ServerResponse {
  ServerResponse({
    this.status = 0,
    this.data = const {},
    this.errors = const [],
  });

  final int status;
  final Map<String, dynamic> data;
  final List<SupabaseFunctionError> errors;

  factory ServerResponse.fromJson(Map<String, dynamic> json) => ServerResponse(
        status: json["status"],
        data: json["data"],
        errors: List<SupabaseFunctionError>.from(
            json["errors"].map((x) => SupabaseFunctionError.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data,
        "errors": List<dynamic>.from(errors.map((x) => x.toJson())),
      };
}
