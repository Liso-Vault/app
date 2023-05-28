import 'package:liso/features/config/app_domains.model.dart';

late ExtraConfig extraConfig;

class ExtraConfig {
  final ExtraConfigSecrets secrets;
  final ExtraConfigWeb3 web3;
  final ExtraAppDomainsConfig appDomains;

  ExtraConfig({
    required this.secrets,
    required this.web3,
    required this.appDomains,
  });

  factory ExtraConfig.fromJson(Map<String, dynamic> json) => ExtraConfig(
        secrets: ExtraConfigSecrets.fromJson(json["secrets"]),
        web3: ExtraConfigWeb3.fromJson(json["web3"]),
        appDomains: ExtraAppDomainsConfig.fromJson(json["appDomains"]),
      );

  Map<String, dynamic> toJson() => {
        "secrets": secrets.toJson(),
        "web3": web3.toJson(),
        "appDomains": appDomains.toJson(),
      };
}

class ExtraConfigSecrets {
  final ExtraConfigS3 s3;
  final ExtraConfigAlchemy alchemy;

  ExtraConfigSecrets({
    required this.s3,
    required this.alchemy,
  });

  factory ExtraConfigSecrets.fromJson(Map<String, dynamic> json) =>
      ExtraConfigSecrets(
        s3: ExtraConfigS3.fromJson(json["s3"]),
        alchemy: ExtraConfigAlchemy.fromJson(json["alchemy"]),
      );

  Map<String, dynamic> toJson() => {
        "s3": s3.toJson(),
        "alchemy": alchemy.toJson(),
      };
}

class ExtraConfigAlchemy {
  final String apiKey;

  ExtraConfigAlchemy({
    required this.apiKey,
  });

  factory ExtraConfigAlchemy.fromJson(Map<String, dynamic> json) =>
      ExtraConfigAlchemy(
        apiKey: json["apiKey"],
      );

  Map<String, dynamic> toJson() => {
        "apiKey": apiKey,
      };
}

class ExtraConfigS3 {
  final String key;
  final String secret;
  final String bucket;
  final String endpoint;

  ExtraConfigS3({
    required this.key,
    required this.secret,
    required this.bucket,
    required this.endpoint,
  });

  factory ExtraConfigS3.fromJson(Map<String, dynamic> json) => ExtraConfigS3(
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
}

class ExtraConfigWeb3 {
  final List<ExtraConfigChain> chains;

  ExtraConfigWeb3({
    required this.chains,
  });

  factory ExtraConfigWeb3.fromJson(Map<String, dynamic> json) =>
      ExtraConfigWeb3(
        chains: List<ExtraConfigChain>.from(
            json["chains"].map((x) => ExtraConfigChain.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "chains": List<dynamic>.from(chains.map((x) => x.toJson())),
      };
}

class ExtraConfigChain {
  final String name;
  final String symbol;
  final int decimals;
  final String logo;
  final ExtraConfigChainUrls main;
  final ExtraConfigChainUrls test;

  ExtraConfigChain({
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.logo,
    required this.main,
    required this.test,
  });

  factory ExtraConfigChain.fromJson(Map<String, dynamic> json) =>
      ExtraConfigChain(
        name: json["name"],
        symbol: json["symbol"],
        decimals: json["decimals"],
        logo: json["logo"],
        main: ExtraConfigChainUrls.fromJson(json["main"]),
        test: ExtraConfigChainUrls.fromJson(json["test"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "symbol": symbol,
        "decimals": decimals,
        "logo": logo,
        "main": main.toJson(),
        "test": test.toJson(),
      };
}

class ExtraConfigChainUrls {
  final String http;
  final String ws;

  ExtraConfigChainUrls({
    required this.http,
    required this.ws,
  });

  factory ExtraConfigChainUrls.fromJson(Map<String, dynamic> json) =>
      ExtraConfigChainUrls(
        http: json["http"],
        ws: json["ws"],
      );

  Map<String, dynamic> toJson() => {
        "http": http,
        "ws": ws,
      };
}
