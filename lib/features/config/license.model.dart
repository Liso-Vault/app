import 'limits.model.dart';

late LicenseConfig licenseConfig;

class LicenseConfig {
  const LicenseConfig({
    // this.max = const ConfigLicenseLimits(),
    this.pro = const ExtraLimitsConfigTier(),
    this.free = const ExtraLimitsConfigTier(),
    this.holder = const ExtraLimitsConfigTier(),
    // this.plus = const ConfigLicenseLimits(),
    // this.starter = const ConfigLicenseLimits(),
    // this.business = const ConfigLicenseLimits(),
  });

  // final ConfigLicenseLimits max;
  final ExtraLimitsConfigTier pro;
  final ExtraLimitsConfigTier free;
  final ExtraLimitsConfigTier holder;
  // final ConfigLicenseLimits plus;
  // final ConfigLicenseLimits starter;
  // final ConfigLicenseLimits business;

  factory LicenseConfig.fromJson(Map<String, dynamic> json) => LicenseConfig(
        // max: ConfigLicenseLimits.fromJson(json["max"]),
        pro: ExtraLimitsConfigTier.fromJson(json["pro"]),
        free: ExtraLimitsConfigTier.fromJson(json["free"]),
        holder: ExtraLimitsConfigTier.fromJson(json["holder"]),
        // plus: ConfigLicenseLimits.fromJson(json["plus"]),
        // starter: ConfigLicenseLimits.fromJson(json["starter"]),
        // business: ConfigLicenseLimits.fromJson(json["business"]),
      );

  Map<String, dynamic> toJson() => {
        // "max": max.toJson(),
        "pro": pro.toJson(),
        "free": free.toJson(),
        "holder": holder.toJson(),
        // "plus": plus.toJson(),
        // "starter": starter.toJson(),
        // "business": business.toJson(),
      };
}
