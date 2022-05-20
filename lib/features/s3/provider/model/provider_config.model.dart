import 's3_provider_config.model.dart';

class SyncProviderConfig {
  SyncProviderConfig({
    required this.type,
    required this.data,
  });

  final String type;
  final SyncProviderConfigS3Data data;

  factory SyncProviderConfig.fromJson(Map<String, dynamic> json) =>
      SyncProviderConfig(
        type: json["type"],
        data: SyncProviderConfigS3Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "data": data.toJson(),
      };
}
