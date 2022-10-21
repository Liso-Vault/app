class SupabaseProfile {
  SupabaseProfile({
    this.id = '',
    this.createdAt,
    this.updatedAt,
    this.gumroadLicenseKey = '',
    this.revenuecatUserId = '',
  });

  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String gumroadLicenseKey;
  final String revenuecatUserId;

  factory SupabaseProfile.fromJson(Map<String, dynamic> json) =>
      SupabaseProfile(
        id: json["id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        gumroadLicenseKey: json["gumroad_license_key"] ?? '',
        revenuecatUserId: json["revenuecat_user_id"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "gumroad_license_key": gumroadLicenseKey,
        "revenuecat_user_id": revenuecatUserId,
      };
}
