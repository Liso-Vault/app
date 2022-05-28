import 'dart:convert';

import 'package:hive/hive.dart';

import 'app.hive.dart';
import 'device.hive.dart';

part 'metadata.hive.g.dart';

@HiveType(typeId: 10)
class HiveMetadata extends HiveObject {
  @HiveField(0)
  HiveMetadataDevice device;
  @HiveField(1)
  HiveMetadataApp app;
  @HiveField(2)
  DateTime createdTime;
  @HiveField(3)
  DateTime updatedTime;

  HiveMetadata({
    required this.device,
    required this.app,
    required this.createdTime,
    required this.updatedTime,
  });

  factory HiveMetadata.fromJson(Map<String, dynamic> json) => HiveMetadata(
        device: HiveMetadataDevice.fromJson(json["device"]),
        app: HiveMetadataApp.fromJson(json["app"]),
        createdTime: DateTime.parse(json["createdTime"]),
        updatedTime: DateTime.parse(json["updatedTime"]),
      );

  Map<String, dynamic> toJson() => {
        "device": device.toJson(),
        "app": app.toJson(),
        "createdTime": createdTime.toIso8601String(),
        "updatedTime": updatedTime.toIso8601String(),
      };

  // GETTERS

  // FUNCTIONS
  // TODO: format time

  String toJsonString() => jsonEncode(toJson());

  Future<HiveMetadata> getUpdated() async {
    return HiveMetadata(
      app: await HiveMetadataApp.get(),
      device: await HiveMetadataDevice.get(),
      createdTime: createdTime,
      updatedTime: DateTime.now().toUtc(),
    );
  }

  static Future<HiveMetadata> get() async {
    return HiveMetadata(
      app: await HiveMetadataApp.get(),
      device: await HiveMetadataDevice.get(),
      createdTime: DateTime.now().toUtc(),
      updatedTime: DateTime.now().toUtc(),
    );
  }

  static Future<Map<String, dynamic>> getJson() async => (await get()).toJson();

  static Future<String> getJsonString() async =>
      jsonEncode((await get()).toJson());
}
