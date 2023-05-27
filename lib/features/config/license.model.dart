late LicenseConfig licenseConfig;

class LicenseConfig {
  const LicenseConfig({
    this.max = const ConfigLicenseLimits(),
    this.pro = const ConfigLicenseLimits(),
    this.free = const ConfigLicenseLimits(),
    this.plus = const ConfigLicenseLimits(),
    this.starter = const ConfigLicenseLimits(),
    this.business = const ConfigLicenseLimits(),
  });

  final ConfigLicenseLimits max;
  final ConfigLicenseLimits pro;
  final ConfigLicenseLimits free;
  final ConfigLicenseLimits plus;
  final ConfigLicenseLimits starter;
  final ConfigLicenseLimits business;

  factory LicenseConfig.fromJson(Map<String, dynamic> json) => LicenseConfig(
        max: ConfigLicenseLimits.fromJson(json["max"]),
        pro: ConfigLicenseLimits.fromJson(json["pro"]),
        free: ConfigLicenseLimits.fromJson(json["free"]),
        plus: ConfigLicenseLimits.fromJson(json["plus"]),
        starter: ConfigLicenseLimits.fromJson(json["starter"]),
        business: ConfigLicenseLimits.fromJson(json["business"]),
      );

  Map<String, dynamic> toJson() => {
        "max": max.toJson(),
        "pro": pro.toJson(),
        "free": free.toJson(),
        "plus": plus.toJson(),
        "starter": starter.toJson(),
        "business": business.toJson(),
      };
}

class ConfigLicenseLimits {
  const ConfigLicenseLimits({
    this.id = '',
    this.users = 0,
    this.devices = 0,
  });

  final String id;
  final int users;
  final int devices;

  factory ConfigLicenseLimits.fromJson(Map<String, dynamic> json) =>
      ConfigLicenseLimits(
        id: json["id"],
        users: json["users"],
        devices: json["devices"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "users": users,
        "devices": devices,
      };
}
