import 'package:minio/models.dart';
import 'package:path/path.dart';

import '../../../core/utils/utils.dart';

class S3Content {
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

  bool get isFile => type == S3ContentType.file;

  String get fileExtension => extension(path);

  String get updatedTimeAgo =>
      object != null ? Utils.timeAgo(object!.lastModified!, short: false) : '';
}

enum S3ContentType {
  file,
  directory,
}
