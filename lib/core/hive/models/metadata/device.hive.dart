import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:hive/hive.dart';

part 'device.hive.g.dart';

@HiveType(typeId: 12)
class HiveMetadataDevice extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String model;
  @HiveField(2)
  String unit;
  @HiveField(3)
  String platform;
  @HiveField(4)
  String osVersion;

  HiveMetadataDevice({
    this.id = '',
    this.model = '',
    this.unit = '',
    this.platform = '',
    this.osVersion = '',
  });

  factory HiveMetadataDevice.fromJson(Map<String, dynamic> json) =>
      HiveMetadataDevice(
        id: json["id"],
        model: json["model"],
        unit: json["unit"],
        platform: json["platform"],
        osVersion: json["osVersion"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "model": model,
        "unit": unit,
        "platform": platform,
        "osVersion": osVersion,
      };

  static Future<HiveMetadataDevice> get() async {
    String _platformName() {
      if (GetPlatform.isAndroid) {
        return "android";
      } else if (GetPlatform.isIOS) {
        return "ios";
      } else if (GetPlatform.isWindows) {
        return "windows";
      } else if (GetPlatform.isMacOS) {
        return "macos";
      } else if (GetPlatform.isLinux) {
        return "linux";
      } else if (GetPlatform.isFuchsia) {
        return "fuchsia";
      } else {
        return "unknown";
      }
    }

    final device = HiveMetadataDevice(platform: _platformName());
    final deviceInfo = DeviceInfoPlugin();

    if (GetPlatform.isIOS) {
      final info = await deviceInfo.iosInfo;
      device.id = info.identifierForVendor!;
      device.osVersion = info.systemVersion!;
      device.model = info.model!;
      device.unit = info.utsname.machine!;
    } else if (GetPlatform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      device.id = info.androidId!;
      device.osVersion = info.version.release!;
      device.model = info.brand!;
      device.unit = info.device!;
    }

    return device;
  }

  static Future<Map<String, dynamic>> getJson() async => (await get()).toJson();
}
