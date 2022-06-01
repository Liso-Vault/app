import 'package:liso/features/s3/model/s3_content.model.dart';

class S3FolderInfo {
  List<S3Content> contents;
  final int totalSize;
  final int encryptedFiles;

  S3FolderInfo({
    this.contents = const [],
    this.totalSize = 0,
    this.encryptedFiles = 0,
  });
}
