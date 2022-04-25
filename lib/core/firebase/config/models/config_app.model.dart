import 'dart:convert';

class ConfigApp {
  const ConfigApp({
    this.id = 'liso',
    this.package = 'com.liso.app',
    this.enabled = true,
    this.build = const ConfigAppBuild(),
    this.settings = const ConfigAppSettings(),
  });

  final String id;
  final String package;
  final bool enabled;
  final ConfigAppBuild build;
  final ConfigAppSettings settings;

  factory ConfigApp.fromJson(Map<String, dynamic> json) => ConfigApp(
        id: json["id"],
        package: json["package"],
        enabled: json["enabled"],
        build: ConfigAppBuild.fromJson(json["build"]),
        settings: ConfigAppSettings.fromJson(json["settings"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "package": package,
        "enabled": enabled,
        "build": build.toJson(),
        "settings": settings.toJson(),
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

class ConfigAppSettings {
  const ConfigAppSettings({
    this.theme = 'system',
    this.maxUnlock = 0,
    this.autoLock = 0,
    this.sync = true,
    this.premium = true,
    this.maxStorageSize = 0,
    this.maxUploadSize = 0,
  });

  final String theme;
  final int maxUnlock;
  final int autoLock;
  final bool sync;
  final bool premium;
  final int maxStorageSize;
  final int maxUploadSize;

  factory ConfigAppSettings.fromJson(Map<String, dynamic> json) =>
      ConfigAppSettings(
        theme: json["theme"],
        maxUnlock: json["max_unlock"],
        autoLock: json["auto_lock"],
        sync: json["sync"],
        premium: json["premium"],
        maxStorageSize: json["max_storage_size"],
        maxUploadSize: json["max_upload_size"],
      );

  Map<String, dynamic> toJson() => {
        "theme": theme,
        "max_unlock": maxUnlock,
        "auto_lock": autoLock,
        "sync": sync,
        "premium": premium,
        "max_storage_size": maxStorageSize,
        "max_upload_size": maxUploadSize,
      };
}
