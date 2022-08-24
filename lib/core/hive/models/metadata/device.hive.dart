import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:hive/hive.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../../../utils/utils.dart';

part 'device.hive.g.dart';

@HiveType(typeId: 222)
class HiveMetadataDevice extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String model;
  @HiveField(3)
  String platform;
  @HiveField(4)
  String osVersion;
  @HiveField(5)
  Map<String, dynamic>? info;

  String docId;

  HiveMetadataDevice({
    this.docId = '',
    this.id = '',
    this.name = '',
    this.model = '',
    this.platform = '',
    this.osVersion = '',
    this.info,
  });

  factory HiveMetadataDevice.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc_) {
    final json = doc_.data()!;
    final device = HiveMetadataDevice.fromJson(json);
    device.docId = doc_.id;
    return device;
  }

  factory HiveMetadataDevice.fromJson(Map<String, dynamic> json) =>
      HiveMetadataDevice(
        id: json["id"],
        name: json["name"],
        model: json["model"],
        platform: json["platform"],
        osVersion: json["osVersion"],
        info: json["info"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "model": model,
        "platform": platform,
        "osVersion": osVersion,
        "info": info,
      };

  static Future<HiveMetadataDevice> get() async {
    final device = HiveMetadataDevice(platform: Utils.platformName());
    final deviceInfo = DeviceInfoPlugin();
    device.id = (await PlatformDeviceId.getDeviceId)!;

    if (GetPlatform.isIOS) {
      final info = await deviceInfo.iosInfo;
      device.osVersion = info.systemVersion ?? '';
      device.name = info.name ?? '';
      device.model = info.utsname.machine ?? '';
      device.info = info.toMap();
    } else if (GetPlatform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      device.osVersion = info.version.release ?? '';
      device.name = info.device ?? '';
      device.model = info.model ?? '';

      // strip unecessary info
      final infoMap = info.toMap();
      infoMap.remove('supportedAbis');
      infoMap.remove('systemFeatures');
      infoMap.remove('supported32BitAbis');
      infoMap.remove('supported64BitAbis');
      device.info = infoMap;
    } else if (GetPlatform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      device.osVersion = info.osRelease;
      device.name = info.computerName;
      device.model = info.model;
      device.info = info.toMap();
    } else if (GetPlatform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      // generate a usable id
      device.name = info.computerName;
      device.info = info.toMap();
    } else if (GetPlatform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      device.osVersion = info.version ?? '';
      device.info = info.toMap();
    }

    return device;
  }

  static Future<Map<String, dynamic>> getJson() async => (await get()).toJson();
}
