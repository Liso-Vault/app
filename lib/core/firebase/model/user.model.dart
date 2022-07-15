import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liso/core/hive/models/metadata/app.hive.dart';
import 'package:purchases_flutter/object_wrappers.dart';

class FirebaseUser {
  FirebaseUser({
    this.docId = '',
    this.userId = '',
    this.address = '',
    this.limits = '',
    this.purchases,
    this.updatedTime,
    this.createdTime,
    this.metadata,
  });

  String docId;
  String userId;
  String address;
  String? limits;
  FirebaseUserPurchases? purchases;
  Timestamp? updatedTime;
  Timestamp? createdTime;
  FirebaseUserMetadata? metadata;

  factory FirebaseUser.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc_) {
    final json = doc_.data()!;
    final user = FirebaseUser.fromJson(json);
    user.docId = doc_.id;
    return user;
  }

  factory FirebaseUser.fromJson(Map<String, dynamic> json) => FirebaseUser(
        userId: json["userId"],
        address: json["address"],
        limits: json["limits"],
        purchases: json["purchases"] == null
            ? null
            : FirebaseUserPurchases.fromJson(json["purchases"]),
        updatedTime: json["updatedTime"] ?? DateTime.now(),
        createdTime: json["createdTime"] ?? DateTime.now(),
        metadata: FirebaseUserMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "address": address,
        "limits": limits,
        "purchases": purchases?.toJson(),
        "updatedTime": FieldValue.serverTimestamp(),
        if (createdTime == null) "createdTime": FieldValue.serverTimestamp(),
        "metadata": metadata?.toJson(),
      };
}

class FirebaseUserMetadata {
  FirebaseUserMetadata({
    this.app,
    this.deviceId,
    this.size,
    this.count,
    this.settings,
  });

  HiveMetadataApp? app;
  String? deviceId;
  FirebaseUserSize? size;
  FirebaseUserCount? count;
  FirebaseUserSettings? settings;

  factory FirebaseUserMetadata.fromJson(Map<String, dynamic> json) =>
      FirebaseUserMetadata(
        app: HiveMetadataApp.fromJson(json["app"]),
        deviceId: json["deviceId"],
        size: FirebaseUserSize.fromJson(json["size"]),
        count: FirebaseUserCount.fromJson(json["count"]),
        settings: FirebaseUserSettings.fromJson(json["settings"]),
      );

  Map<String, dynamic> toJson() => {
        "app": app?.toJson(),
        "deviceId": deviceId,
        "size": size?.toJson(),
        "count": count?.toJson(),
        "settings": settings?.toJson(),
      };
}

class FirebaseUserCount {
  FirebaseUserCount({
    this.items = 0,
    this.groups = 0,
    this.categories = 0,
    this.files = 0,
    this.encryptedFiles = 0,
    this.sharedVaults = 0,
    this.joinedVaults = 0,
  });

  int? items;
  int? groups;
  int? categories;
  int? files;
  int? encryptedFiles;
  int? sharedVaults;
  int? joinedVaults;

  factory FirebaseUserCount.fromJson(Map<String, dynamic> json) =>
      FirebaseUserCount(
        items: json["items"],
        groups: json["groups"],
        categories: json["categories"],
        files: json["files"],
        encryptedFiles: json["encrypted_files"],
        sharedVaults: json["shared_vaults"],
        joinedVaults: json["joined_vaults"],
      );

  Map<String, dynamic> toJson() => {
        "items": items,
        "groups": groups,
        "categories": categories,
        "files": files,
        "encrypted_files": encryptedFiles,
        "shared_vaults": sharedVaults,
        "joined_vaults": joinedVaults,
      };
}

class FirebaseUserSettings {
  FirebaseUserSettings({
    this.theme = '',
    this.syncProvider = '',
    this.localeCode = '',
    this.sync = false,
    this.backedUpSeed = false,
    this.crashReporting = false,
    this.analytics = false,
    this.biometrics = false,
  });

  String? theme;
  String? syncProvider;
  String? localeCode;
  bool? sync;
  bool? backedUpSeed;
  bool? crashReporting;
  bool? analytics;
  bool? biometrics;

  factory FirebaseUserSettings.fromJson(Map<String, dynamic> json) =>
      FirebaseUserSettings(
        sync: json["sync"],
        theme: json["theme"],
        syncProvider: json["syncProvider"],
        backedUpSeed: json["backedUpSeed"],
        localeCode: json["localeCode"],
        crashReporting: json["crashReporting"],
        analytics: json["analytics"],
        biometrics: json["biometrics"],
      );

  Map<String, dynamic> toJson() => {
        "sync": sync,
        "theme": theme,
        "syncProvider": syncProvider,
        "backedUpSeed": backedUpSeed,
        "localeCode": localeCode,
        "crashReporting": crashReporting,
        "analytics": analytics,
        "biometrics": biometrics,
      };
}

class FirebaseUserSize {
  FirebaseUserSize({
    this.storage = 0,
    this.vault = 0,
  });

  int storage;
  int vault;

  factory FirebaseUserSize.fromJson(Map<String, dynamic> json) =>
      FirebaseUserSize(
        storage: json["storage"],
        vault: json["vault"],
      );

  Map<String, dynamic> toJson() => {
        "storage": storage,
        "vault": vault,
      };
}

class FirebaseUserPurchases {
  FirebaseUserPurchases({
    this.rcPurchaserInfo,
  });

  PurchaserInfo? rcPurchaserInfo;

  factory FirebaseUserPurchases.fromJson(Map<String, dynamic> json) =>
      FirebaseUserPurchases(
        rcPurchaserInfo: PurchaserInfo.fromJson(json["rcPurchaserInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "rcPurchaserInfo": rcPurchaserInfo?.toJson(),
      };
}
