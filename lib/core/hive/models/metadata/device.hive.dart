import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:hive/hive.dart';

part 'device.hive.g.dart';

@HiveType(typeId: 222)
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
  @HiveField(5)
  Map<String, dynamic> info;

  HiveMetadataDevice({
    this.id = '',
    this.model = '',
    this.unit = '',
    this.platform = '',
    this.osVersion = '',
    this.info = const {},
  });

  factory HiveMetadataDevice.fromJson(Map<String, dynamic> json) =>
      HiveMetadataDevice(
        id: json["id"],
        model: json["model"],
        unit: json["unit"],
        platform: json["platform"],
        osVersion: json["osVersion"],
        info: json["info"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "model": model,
        "unit": unit,
        "platform": platform,
        "osVersion": osVersion,
        "info": info,
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
      // device.info = info.toMap();
      device.id = info.identifierForVendor!;
      device.osVersion = info.systemVersion!;
      device.model = info.model!;
      device.unit = info.utsname.machine!;
    } else if (GetPlatform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      // device.info = info.toMap();
      device.id = info.androidId!;
      device.osVersion = info.version.release!;
      device.model = info.brand!;
      device.unit = info.device!;
    } else if (GetPlatform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      // device.info = info.toMap();
      device.id = info.systemGUID!;
      device.osVersion = info.osRelease;
      device.model = info.model;
      device.unit = info.hostName;
    } else if (GetPlatform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      // device.info = info.toMap();
      // generate a usable id
      device.id =
          '${info.computerName}-${info.numberOfCores}-${info.systemMemoryInMegabytes}';
      // device.osVersion = info.version.release!;
      // device.model = info.brand!;
      // device.unit = info.device!;
    } else if (GetPlatform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      // device.info = info.toMap();
      device.id = info.machineId!;
      device.osVersion = info.version!;
      // device.model = info.name;
      // device.unit = info.;
    }

    return device;
  }

  static Future<Map<String, dynamic>> getJson() async => (await get()).toJson();
}
