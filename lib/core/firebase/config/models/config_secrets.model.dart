import 'dart:convert';

import 'package:get/utils.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';

class ConfigSecrets {
  const ConfigSecrets({
    this.s3 = const ConfigSecretsS3(),
    this.revenuecat = const ConfigSecretsRevenuecat(),
    this.alchemy = const ConfigSecretsAlchemy(),
    this.sentry = const ConfigSecretsSentry(),
  });

  final ConfigSecretsS3 s3;
  final ConfigSecretsRevenuecat revenuecat;
  final ConfigSecretsAlchemy alchemy;
  final ConfigSecretsSentry sentry;

  factory ConfigSecrets.fromJson(Map<String, dynamic> json) => ConfigSecrets(
        s3: ConfigSecretsS3.fromJson(json["s3"]),
        revenuecat: ConfigSecretsRevenuecat.fromJson(json["revenuecat"]),
        alchemy: ConfigSecretsAlchemy.fromJson(json["alchemy"]),
        sentry: ConfigSecretsSentry.fromJson(json["sentry"]),
      );

  Map<String, dynamic> toJson() => {
        "s3": s3.toJson(),
        "revenuecat": revenuecat.toJson(),
        "alchemy": alchemy.toJson(),
        "sentry": sentry.toJson(),
      };
}

class ConfigSecretsAlchemy {
  const ConfigSecretsAlchemy({
    this.apiKey = '',
  });

  final String apiKey;

  factory ConfigSecretsAlchemy.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsAlchemy(
        apiKey: json["apiKey"],
      );

  Map<String, dynamic> toJson() => {
        "apiKey": apiKey,
      };
}

class ConfigSecretsRevenuecat {
  const ConfigSecretsRevenuecat({
    this.appleApiKey = '',
    this.googleApiKey = '',
  });

  final String appleApiKey;
  final String googleApiKey;

  factory ConfigSecretsRevenuecat.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsRevenuecat(
        appleApiKey: json["appleApiKey"],
        googleApiKey: json["googleApiKey"],
      );

  Map<String, dynamic> toJson() => {
        "appleApiKey": appleApiKey,
        "googleApiKey": googleApiKey,
      };

  String get apiKey {
    if (GetPlatform.isAndroid) {
      return googleApiKey;
    } else {
      return appleApiKey;
    }
  }
}

class ConfigSecretsS3 {
  const ConfigSecretsS3({
    this.key = '',
    this.secret = '',
    this.bucket = '',
    this.endpoint = '',
  });

  final String key;
  final String secret;
  final String bucket;
  final String endpoint;

  factory ConfigSecretsS3.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsS3(
        key: json["key"],
        secret: json["secret"],
        bucket: json["bucket"],
        endpoint: json["endpoint"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "secret": secret,
        "bucket": bucket,
        "endpoint": endpoint,
      };

  String toJsonString() => jsonEncode(toJson());

  String get preferredBucket {
    if (Persistence.to.syncProvider.val == LisoSyncProvider.custom.name) {
      return Persistence.to.s3Bucket.val;
    } else {
      return 'liso-${Persistence.to.syncProvider.val}';
    }
  }
}

class ConfigSecretsSentry {
  const ConfigSecretsSentry({
    this.dsn = '',
  });

  final String dsn;

  factory ConfigSecretsSentry.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsSentry(
        dsn: json["dsn"],
      );

  Map<String, dynamic> toJson() => {
        "dsn": dsn,
      };
}
