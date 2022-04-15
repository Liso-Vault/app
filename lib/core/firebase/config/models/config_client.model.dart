import 'dart:convert';

class ConfigClient {
  const ConfigClient({
    this.id = 'liso',
    this.package = 'com.liso.app',
    this.enabled = true,
    this.name = const ConfigClientName(),
    this.build = const ConfigClientBuild(),
    this.emails = const ConfigClientEmails(),
    this.settings = const ConfigClientSettings(),
  });

  final String id;
  final String package;
  final bool enabled;
  final ConfigClientName name;
  final ConfigClientBuild build;
  final ConfigClientEmails emails;
  final ConfigClientSettings settings;

  factory ConfigClient.fromJson(Map<String, dynamic> json) => ConfigClient(
        id: json["id"],
        package: json["package"],
        enabled: json["enabled"],
        name: ConfigClientName.fromJson(json["name"]),
        build: ConfigClientBuild.fromJson(json["build"]),
        emails: ConfigClientEmails.fromJson(json["emails"]),
        settings: ConfigClientSettings.fromJson(json["settings"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "package": package,
        "enabled": enabled,
        "name": name.toJson(),
        "build": build.toJson(),
        "emails": emails.toJson(),
        "settings": settings.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());
}

class ConfigClientBuild {
  const ConfigClientBuild({
    this.latest = 0,
    this.min = 0,
    this.disabled = const [],
  });

  final int latest;
  final int min;
  final List<int> disabled;

  factory ConfigClientBuild.fromJson(Map<String, dynamic> json) =>
      ConfigClientBuild(
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

class ConfigClientEmails {
  const ConfigClientEmails({
    this.support = 'support@liso.app',
    this.error = 'error@liso.app',
    this.translation = 'translation@liso.app',
    this.premium = 'premium@liso.app',
  });

  final String support;
  final String error;
  final String translation;
  final String premium;

  factory ConfigClientEmails.fromJson(Map<String, dynamic> json) =>
      ConfigClientEmails(
        support: json["support"],
        error: json["error"],
        translation: json["translation"],
        premium: json["premium"],
      );

  Map<String, dynamic> toJson() => {
        "support": support,
        "error": error,
        "translation": translation,
        "premium": premium,
      };
}

class ConfigClientName {
  const ConfigClientName({
    this.short = 'Liso',
    this.long = 'Liso',
  });

  final String short;
  final String long;

  factory ConfigClientName.fromJson(Map<String, dynamic> json) =>
      ConfigClientName(
        short: json["short"],
        long: json["long"],
      );

  Map<String, dynamic> toJson() => {
        "short": short,
        "long": long,
      };

  ConfigClientName.empty(this.short, this.long);
}

class ConfigClientSettings {
  const ConfigClientSettings({
    this.theme = 'system',
    this.maxUnlock = 5,
    this.autoLock = 30,
  });

  final String theme;
  final int maxUnlock;
  final int autoLock;

  factory ConfigClientSettings.fromJson(Map<String, dynamic> json) =>
      ConfigClientSettings(
        theme: json["theme"],
        maxUnlock: json["max_unlock"],
        autoLock: json["auto_lock"],
      );

  Map<String, dynamic> toJson() => {
        "theme": theme,
        "max_unlock": maxUnlock,
        "auto_lock": autoLock,
      };
}
