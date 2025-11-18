// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'app_domain.hive.g.dart';

@HiveType(typeId: 30)
class HiveAppDomain extends HiveObject with EquatableMixin {
  @HiveField(0)
  String title;
  @HiveField(1)
  String iconUrl;
  // @HiveField(2)
  // List<HiveDomain> domains;
  @HiveField(3)
  List<String> appIds;
  @HiveField(4)
  List<String> uris;

  HiveAppDomain({
    required this.title,
    this.iconUrl = '',
    this.uris = const [],
    this.appIds = const [],
  });

  factory HiveAppDomain.fromJson(Map<String, dynamic> json) => HiveAppDomain(
        title: json["title"],
        iconUrl: json["icon_url"],
        uris: json["uris"] == null
            ? []
            : List<String>.from(json["uris"].map((x) => x)),
        appIds: List<String>.from(json["app_ids"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "icon_url": iconUrl,
        "uris": List<dynamic>.from(uris.map((x) => x)),
        "app_ids": List<dynamic>.from(appIds.map((x) => x)),
      };

  @override
  List<Object?> get props => [title, iconUrl, uris, appIds];
}
