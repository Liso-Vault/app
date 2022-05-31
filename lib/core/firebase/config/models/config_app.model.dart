import 'dart:convert';

class ConfigApp {
  const ConfigApp({
    this.id = '',
    this.package = '',
    this.enabled = true,
    this.build = const ConfigAppBuild(),
    this.beta = const ConfigAppBeta(),
  });

  final String id;
  final String package;
  final bool enabled;
  final ConfigAppBuild build;
  final ConfigAppBeta beta;

  factory ConfigApp.fromJson(Map<String, dynamic> json) => ConfigApp(
        id: json["id"],
        package: json["package"],
        enabled: json["enabled"],
        build: ConfigAppBuild.fromJson(json["build"]),
        beta: ConfigAppBeta.fromJson(json["beta"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "package": package,
        "enabled": enabled,
        "build": build.toJson(),
        "beta": beta.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());
}

class ConfigAppBuild {
  const ConfigAppBuild({
    this.latest = 0,
    this.min = 0,
    this.disabled = const [],
  });

  final int latest;
  final int min;
  final List<int> disabled;

  factory ConfigAppBuild.fromJson(Map<String, dynamic> json) => ConfigAppBuild(
        latest: json["latest"],
        min: json["min"],
        disabled: List<int>.from(json["disabled"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "latest": latest,
        "min": min,
        "disabled": List<dynamic>.from(disabled.map((x) => x)),
      };
}

class ConfigAppBeta {
  const ConfigAppBeta({
    this.latest = 0,
    this.min = 0,
    this.enabled = true,
  });

  final int latest;
  final int min;
  final bool enabled;

  factory ConfigAppBeta.fromJson(Map<String, dynamic> json) => ConfigAppBeta(
        latest: json["latest"],
        min: json["min"],
        enabled: json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "latest": latest,
        "min": min,
        "enabled": enabled,
      };
}
