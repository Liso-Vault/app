class S3FolderInfo {
  List<Object> objects;
  final int totalSize;

  S3FolderInfo({
    this.objects = const [],
    this.totalSize = 0,
  });
}
