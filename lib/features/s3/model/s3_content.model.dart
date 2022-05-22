import 'package:console_mixin/console_mixin.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart';

import '../../../core/utils/minio.util.dart';
import '../../../core/utils/utils.dart';
import '../explorer/file_extensions.dart';

class S3Content with ConsoleMixin {
  final String name;
  final String path;
  final int size;
  final S3ContentType type;
  final Object? object;

  S3Content({
    this.name = '',
    required this.path,
    this.size = 0,
    this.type = S3ContentType.directory,
    this.object,
  });

  factory S3Content.fromJson(Map<String, dynamic> json) => S3Content(
        name: json["name"],
        path: json["path"],
        size: json["size"],
        type: S3ContentType.values.byName(json["type"]),
        object: MinioUtil.objectFromJson(json["object"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "path": path,
      "size": size,
      "type": type.name,
      "object": MinioUtil.objectToJson(object),
    };
  }

  bool get isVaultFile => fileExtension == kVaultExtension;

  bool get isFile => type == S3ContentType.file;

  bool get isEncrypted => name.contains(kEncryptedExtensionExtra);

  String get fileExtension => extension(maskedName).replaceAll('.', '');

  String get updatedTimeAgo =>
      object != null ? Utils.timeAgo(object!.lastModified!, short: false) : '';

  String get maskedName => name.replaceAll(kEncryptedExtensionExtra, '');

  String? get fileType {
    final extensionType = kFileExtensionsMap[fileExtension]?.first;
    return extensionType;
  }
}

enum S3ContentType {
  file,
  directory,
}

enum S3FileType {
  text,
  image,
  pdf,
  unknown,
}
