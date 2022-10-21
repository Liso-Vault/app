class SyncUserResponse {
  SyncUserResponse({
    this.profileId = '',
    this.deviceId = '',
    this.sessionId = 0,
    this.licenseKey = '',
    this.rcUserId = '',
  });

  final String profileId;
  final String deviceId;
  final int sessionId;
  final String licenseKey;
  final String rcUserId;

  factory SyncUserResponse.fromJson(Map<String, dynamic> json) =>
      SyncUserResponse(
        profileId: json["profileId"],
        deviceId: json["deviceId"],
        sessionId: json["sessionId"],
        licenseKey: json["licenseKey"] ?? '',
        rcUserId: json["rcUserId"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "profileId": profileId,
        "deviceId": deviceId,
        "sessionId": sessionId,
        "licenseKey": licenseKey,
        "rcUserId": rcUserId,
      };
}
