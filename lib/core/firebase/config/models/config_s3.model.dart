import 'dart:convert';

import 'package:liso/core/services/persistence.service.dart';

class ConfigS3 {
  const ConfigS3({
    this.key = '',
    this.secret = '',
    this.bucket = '',
    this.endpoint = '',
  });

  final String key;
  final String secret;
  final String bucket;
  final String endpoint;

  factory ConfigS3.fromJson(Map<String, dynamic> json) => ConfigS3(
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

  String get preferredBucket =>
      'liso-${PersistenceService.to.syncProvider.val}';
}
