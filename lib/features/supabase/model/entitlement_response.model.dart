class EntitlementResponse {
  EntitlementResponse({
    this.entitled = false,
    this.expiresAt,
  });

  final bool entitled;
  final DateTime? expiresAt;

  factory EntitlementResponse.fromJson(Map<String, dynamic> json) =>
      EntitlementResponse(
        entitled: json["entitled"],
        expiresAt: json["expires_at"] == null
            ? null
            : DateTime.parse(json["expires_at"]),
      );

  Map<String, dynamic> toJson() => {
        "entitled": entitled,
        "expires_at": expiresAt?.toIso8601String(),
      };
}
