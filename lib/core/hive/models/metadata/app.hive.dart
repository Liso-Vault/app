import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'app.hive.g.dart';

@HiveType(typeId: 11)
class HiveMetadataApp extends HiveObject {
  @HiveField(0)
  String appName;
  @HiveField(1)
  String packageName;
  @HiveField(2)
  String version;
  @HiveField(3)
  String buildNumber;

  HiveMetadataApp({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  factory HiveMetadataApp.fromJson(Map<String, dynamic> json) =>
      HiveMetadataApp(
        appName: json["appName"],
        packageName: json["packageName"],
        version: json["version"],
        buildNumber: json["buildNumber"],
      );

  Map<String, dynamic> toJson() => {
        "appName": appName,
        "packageName": packageName,
        "version": version,
        "buildNumber": buildNumber,
      };

  static Future<HiveMetadataApp> get() async {
    final packageInfo = await PackageInfo.fromPlatform();

    return HiveMetadataApp(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }

  static Future<Map<String, dynamic>> getJson() async => (await get()).toJson();
}
