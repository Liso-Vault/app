class SupabaseDevice {
  SupabaseDevice({
    this.id = 0,
    this.userId = '',
    this.createdAt,
    this.updatedAt,
    this.platform = '',
    this.info = const {},
    this.deviceId = '',
  });

  final int id;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String platform;
  final Map<String, dynamic>? info;
  final String deviceId;

  factory SupabaseDevice.fromJson(Map<String, dynamic> json) => SupabaseDevice(
        id: json["id"],
        userId: json["user_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        platform: json["platform"],
        info: json["info"],
        deviceId: json["device_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "platform": platform,
        "info": info,
        "device_id": deviceId,
      };
}
