import 'package:liso/core/hive/models/app_domain.hive.dart';

class ExtraAppDomainsConfig {
  const ExtraAppDomainsConfig({
    this.version = 0,
    this.data = const [],
  });

  final int version;
  final List<HiveAppDomain> data;

  factory ExtraAppDomainsConfig.fromJson(Map<String, dynamic> json) =>
      ExtraAppDomainsConfig(
        version: json["version"],
        data: List<HiveAppDomain>.from(
            json["data"].map((x) => HiveAppDomain.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}
