class S3Object {
  const S3Object({
    this.type = '',
    this.key = '',
    this.etag = '',
    this.size = 0,
    this.lastModified,
  });

  final String? type;
  final String? key;
  final String? etag;
  final int? size;
  final DateTime? lastModified;

  factory S3Object.fromJson(Map<String, dynamic> json) => S3Object(
        type: json["type"],
        key: json["key"],
        etag: json["etag"],
        size: json["size"],
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
}
