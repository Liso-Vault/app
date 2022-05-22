import 'dart:convert';

import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';

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

  String get preferredBucket {
    if (Persistence.to.syncProvider.val == LisoSyncProvider.custom.name) {
      return Persistence.to.s3Bucket.val;
    } else {
      return 'liso-${Persistence.to.syncProvider.val}';
    }
  }
}
