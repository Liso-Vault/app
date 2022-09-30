import 'error.model.dart';

class PresignUrlResponse {
  PresignUrlResponse({
    this.status = 0,
    this.data = const PresignedData(),
    this.errors = const [],
  });

  final int status;
  final PresignedData data;
  final List<SupabaseFunctionError> errors;

  factory PresignUrlResponse.fromJson(Map<String, dynamic> json) =>
      PresignUrlResponse(
        status: json["status"],
        data: PresignedData.fromJson(json["data"]),
        errors: List<SupabaseFunctionError>.from(
            json["errors"].map((x) => SupabaseFunctionError.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "errors": List<dynamic>.from(errors.map((x) => x.toJson())),
      };
}

class PresignedData {
  const PresignedData({
    this.url = '',
    this.method = '',
    this.expirationDate,
  });

  final String url;
  final String method;
  final DateTime? expirationDate;

  factory PresignedData.fromJson(Map<String, dynamic> json) => PresignedData(
        url: json["url"],
        method: json["method"],
        expirationDate: DateTime.parse(json["expirationDate"]),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "method": method,
        "expirationDate": expirationDate?.toIso8601String(),
      };

  bool get expired => DateTime.now().isAfter(expirationDate!);
}
