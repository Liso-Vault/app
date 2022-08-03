import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'app_domain.hive.g.dart';

@HiveType(typeId: 30)
class HiveAppDomain extends HiveObject with EquatableMixin {
  @HiveField(0)
  String title;
  @HiveField(1)
  String iconUrl;
  @HiveField(2)
  List<HiveDomain> domains;
  @HiveField(3)
  List<String> appIds;

  HiveAppDomain({
    required this.title,
    this.iconUrl = '',
    this.domains = const [],
    this.appIds = const [],
  });

  factory HiveAppDomain.fromJson(Map<String, dynamic> json) => HiveAppDomain(
        title: json["title"],
        iconUrl: json["icon_url"],
        domains: List<HiveDomain>.from(
            json["domains"].map((x) => HiveDomain.fromJson(x))),
        appIds: List<String>.from(json["app_ids"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "icon_url": iconUrl,
        "domains": List<dynamic>.from(domains.map((x) => x.toJson())),
        "app_ids": List<dynamic>.from(appIds.map((x) => x)),
      };

  @override
  List<Object?> get props => [title, iconUrl, domains, appIds];

  String get website => domains.isNotEmpty
      ? '${domains.first.scheme}://${domains.first.domain}'
      : '';
}

@HiveType(typeId: 31)
class HiveDomain extends HiveObject with EquatableMixin {
  HiveDomain({
    this.scheme = '',
    this.domain = '',
  });

  final String? scheme;
  final String domain;

  factory HiveDomain.fromJson(Map<String, dynamic> json) => HiveDomain(
        scheme: json["scheme"],
        domain: json["domain"],
      );

  Map<String, dynamic> toJson() => {
        "scheme": scheme,
        "domain": domain,
      };

  @override
  List<Object?> get props => [scheme, domain];
}
