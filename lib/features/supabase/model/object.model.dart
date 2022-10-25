import 'package:app_core/utils/utils.dart';
import 'package:path/path.dart';

import '../../../core/utils/globals.dart';
import '../../../features/files/explorer/file_extensions.dart';

class S3Object {
  const S3Object({
    this.type = '',
    this.key = '',
    this.etag = '',
    this.size = 0,
    this.lastModified,
  });

  final String type;
  final String key;
  final String etag;
  final int size;
  final DateTime? lastModified;

  factory S3Object.fromJson(Map<String, dynamic> json) => S3Object(
        type: json["type"] ?? '',
        key: json["key"] ?? '',
        etag: json["etag"] ?? '',
        size: json["size"] ?? 0,
        lastModified: json["lastModified"] != null
            ? DateTime.parse(json["lastModified"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "key": key,
        "etag": etag,
        "size": size,
        "lastModified": lastModified?.toIso8601String(),
      };

  String get name => basename(key);

  bool get isVaultFile => fileExtension == kVaultExtension;

  bool get isFile => extension(key).isNotEmpty;

  bool get isEncrypted => key.contains(kEncryptedExtensionExtra);

  String get fileExtension => extension(maskedName).replaceAll('.', '');

  String get updatedTimeAgo => Utils.timeAgo(lastModified!, short: false);

  String get maskedName => name.replaceAll(kEncryptedExtensionExtra, '');

  String? get fileType {
    final extensionType = kFileExtensionsMap[fileExtension]?.first;
    return extensionType;
  }
}

enum S3ObjectType {
  file,
  directory,
}

enum S3FileType {
  text,
  image,
  pdf,
  unknown,
}
