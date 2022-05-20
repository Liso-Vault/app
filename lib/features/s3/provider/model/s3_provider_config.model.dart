class SyncProviderConfigS3Data {
  SyncProviderConfigS3Data({
    required this.endpoint,
    required this.accessKey,
    required this.secretKey,
    this.enableTrace = false,
    this.port,
    this.region,
    this.sessionToken,
    this.useSsl = true,
  });

  final String endpoint;
  final String accessKey;
  final String secretKey;
  final bool enableTrace;
  final int? port;
  final String? region;
  final String? sessionToken;
  final bool useSsl;

  factory SyncProviderConfigS3Data.fromJson(Map<String, dynamic> json) =>
      SyncProviderConfigS3Data(
        endpoint: json["endpoint"],
        accessKey: json["access_key"],
        secretKey: json["secret_key"],
        enableTrace: json["enable_trace"],
        port: json["port"],
        region: json["region"],
        sessionToken: json["session_token"],
        useSsl: json["use_ssl"],
      );

  Map<String, dynamic> toJson() => {
        "endpoint": endpoint,
        "access_key": accessKey,
        "secret_key": secretKey,
        "enable_trace": enableTrace,
        "port": port,
        "region": region,
        "session_token": sessionToken,
        "use_ssl": useSsl,
      };
}
