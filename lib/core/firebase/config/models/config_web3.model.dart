class ConfigWeb3 {
  const ConfigWeb3({
    this.chains = const [],
  });

  final List<Chain> chains;

  factory ConfigWeb3.fromJson(Map<String, dynamic> json) => ConfigWeb3(
        chains: List<Chain>.from(json["chains"].map((x) => Chain.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "chains": List<dynamic>.from(chains.map((x) => x.toJson())),
      };
}

class Chain {
  const Chain({
    this.name = '',
    this.symbol = '',
    this.decimals = 0,
    this.logo = '',
    this.main = const Network(),
    this.test = const Network(),
  });

  final String name;
  final String symbol;
  final int decimals;
  final String logo;
  final Network main;
  final Network test;

  factory Chain.fromJson(Map<String, dynamic> json) => Chain(
        name: json["name"],
        symbol: json["symbol"],
        decimals: json["decimals"],
        logo: json["logo"],
        main: Network.fromJson(json["main"]),
        test: Network.fromJson(json["test"]),
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

class Network {
  const Network({
    this.http = '',
    this.ws = '',
  });

  final String http;
  final String ws;

  factory Network.fromJson(Map<String, dynamic> json) => Network(
        http: json["http"],
        ws: json["ws"],
      );

  Map<String, dynamic> toJson() => {
        "http": http,
        "ws": ws,
      };
}
