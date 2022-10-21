import 'dart:convert';
import 'dart:io';

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

    if (GetPlatform.isWeb) {
      // TODO: obtain userAgent
      device.info = {'userAgent': ''};
    } else if (GetPlatform.isIOS) {
      final info = await deviceInfo.iosInfo;
      device.osVersion = info.systemVersion ?? '';
      device.name = info.name ?? '';
      device.model = info.utsname.machine ?? '';
      device.info = {
        'identifierForVendor': info.identifierForVendor,
        'isPhysicalDevice': info.isPhysicalDevice,
        'systemName': info.systemName,
      };
    } else if (GetPlatform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      device.osVersion = info.version.release;
      device.name = info.device;
      device.model = info.model;
      device.info = {
        'id': info.id,
        'brand': info.brand,
        'display': info.display,
        'manufacturer': info.manufacturer,
        'product': info.product,
        'host': info.host,
      };
    } else if (GetPlatform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      device.osVersion = info.osRelease;
      device.name = info.computerName;
      device.model = info.model;
      device.info = {
        'activeCPUs': info.activeCPUs,
        'arch': info.arch,
        'cpuFrequency': info.cpuFrequency,
        'hostName': info.hostName,
        'kernelVersion': info.kernelVersion,
        'memorySize': info.memorySize,
        'systemGUID': info.systemGUID,
      };
    } else if (GetPlatform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      device.id = info.deviceId.replaceAll('{', '').replaceAll('}', '');
      device.name = info.computerName;
      device.osVersion = '${info.productName} ${info.displayVersion}';
      device.info = {
        'majorVersion': info.majorVersion,
        'minorVersion': info.minorVersion,
        'platformId': info.platformId,
        'editionId': info.editionId,
        'releaseId': info.releaseId,
        'systemMemoryInMegabytes': info.systemMemoryInMegabytes,
      };
    } else if (GetPlatform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      device.osVersion = info.version ?? '';
      device.name = info.prettyName;
      device.model = info.variant ?? '';
      device.info = {
        'buildId': info.buildId,
        'variantId': info.variantId,
        'machineId': info.machineId,
        'name': info.name,
        'versionCodename': info.versionCodename,
        'versionId': info.versionId,
      };
    }

    return device;
  }

  // manually obtain device id via process to avoid flashing window bug
  // https://github.com/BestBurning/platform_device_id/issues/15
  static Future<String> getWindowsDeviceID() async {
    final process = await Process.start(
      'wmic',
      ['csproduct', 'get', 'UUID'],
      mode: ProcessStartMode.detachedWithStdio,
    );

    final result = await process.stdout.transform(utf8.decoder).toList();
    String deviceId = '';

    for (var element in result) {
      final item = element.replaceAll(RegExp('\r|\n|\\s|UUID|uuid'), '');
      if (item.isNotEmpty) {
        deviceId = item;
      }
    }

    return deviceId;
  }

  static Future<Map<String, dynamic>> getJson() async => (await get()).toJson();
}
