import 'package:hive/hive.dart';
import 'package:liso/core/utils/utils.dart';

import 'app.hive.dart';
import 'device.hive.dart';

part 'metadata.hive.g.dart';

@HiveType(typeId: 10)
class HiveMetadata extends HiveObject {
  @HiveField(0)
  HiveDevice device;
  @HiveField(1)
  HiveApp app;
  @HiveField(2)
  DateTime createdTime;
  @HiveField(3)
  DateTime updatedTime;

  // TODO: format time

  // GETTERS
  String get updatedTimeAgo => Utils.timeAgo(updatedTime);

  HiveMetadata({
    required this.device,
    required this.app,
    required this.createdTime,
    required this.updatedTime,
  });

  factory HiveMetadata.fromJson(Map<String, dynamic> json) => HiveMetadata(
        device: HiveDevice.fromJson(json["device"]),
        app: HiveApp.fromJson(json["app"]),
        createdTime: DateTime.parse(json["createdTime"]),
        updatedTime: DateTime.parse(json["updatedTime"]),
      );

  Map<String, dynamic> toJson() => {
        "device": device.toJson(),
        "app": app.toJson(),
        "createdTime": createdTime.toIso8601String(),
        "updatedTime": updatedTime.toIso8601String(),
      };

  Future<HiveMetadata> getUpdated() async {
    return HiveMetadata(
      app: await HiveApp.get(),
      device: await HiveDevice.get(),
      createdTime: createdTime,
      updatedTime: DateTime.now().toUtc(),
    );
  }

  static Future<HiveMetadata> get() async {
    return HiveMetadata(
      app: await HiveApp.get(),
      device: await HiveDevice.get(),
      createdTime: DateTime.now().toUtc(),
      updatedTime: DateTime.now().toUtc(),
    );
  }

  static Future<Map<String, dynamic>> getJson() async => (await get()).toJson();
}
