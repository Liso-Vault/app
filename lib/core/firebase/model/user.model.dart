import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liso/core/hive/models/metadata/app.hive.dart';

class FirebaseUser {
  FirebaseUser({
    this.docId = '',
    this.userId = '',
    this.address = '',
    this.limits = '',
    this.updatedTime,
    this.createdTime,
    this.metadata,
  });

  String docId;
  String userId;
  String address;
  String? limits;
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
        updatedTime: json["updatedTime"],
        createdTime: json["createdTime"],
        metadata: FirebaseUserMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "address": address,
        "limits": limits,
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
    this.files = 0,
    this.encryptedFiles = 0,
    this.sharedVaults = 0,
    this.joinedVaults = 0,
  });

  int items;
  int groups;
  int files;
  int encryptedFiles;
  int sharedVaults;
  int joinedVaults;

  factory FirebaseUserCount.fromJson(Map<String, dynamic> json) =>
      FirebaseUserCount(
        items: json["items"],
        groups: json["groups"],
        files: json["files"],
        encryptedFiles: json["encrypted_files"],
        sharedVaults: json["shared_vaults"],
        joinedVaults: json["joined_vaults"],
      );

  Map<String, dynamic> toJson() => {
        "items": items,
        "groups": groups,
        "files": files,
        "encrypted_files": encryptedFiles,
        "shared_vaults": sharedVaults,
        "joined_vaults": joinedVaults,
      };
}

class FirebaseUserSettings {
  FirebaseUserSettings({
    this.sync = false,
    this.theme = '',
  });

  bool sync;
  String theme;

  factory FirebaseUserSettings.fromJson(Map<String, dynamic> json) =>
      FirebaseUserSettings(
        sync: json["sync"],
        theme: json["theme"],
      );

  Map<String, dynamic> toJson() => {
        "sync": sync,
        "theme": theme,
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
