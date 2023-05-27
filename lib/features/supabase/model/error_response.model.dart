class ErrorResponse {
  const ErrorResponse({
    this.error = const ErrorData(),
  });

  final ErrorData error;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        error: ErrorData.fromJson(json["error"]),
      );

  Map<String, dynamic> toJson() => {
        "error": error.toJson(),
      };
}

class ErrorData {
  const ErrorData({
    this.message = '',
    this.type = '',
    this.param = '',
    this.code = '',
  });

  final String message;
  final String? type;
  final String? param;
  final String? code;

  factory ErrorData.fromJson(Map<String, dynamic> json) => ErrorData(
        message: json["message"],
        type: json["type"],
        param: json["param"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "type": type,
        "param": param,
        "code": code,
      };
}
