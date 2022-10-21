class SupabaseFunctionError {
  SupabaseFunctionError({
    this.code = 0,
    this.message = '',
  });

  final int code;
  final String message;

  factory SupabaseFunctionError.fromJson(Map<String, dynamic> json) =>
      SupabaseFunctionError(
        code: json["code"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
      };
}
