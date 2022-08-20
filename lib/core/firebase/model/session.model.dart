import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liso/core/hive/models/metadata/app.hive.dart';
import 'package:liso/core/utils/globals.dart';

class FirebaseUserSession {
  FirebaseUserSession({
    this.docId = '',
    this.app,
    this.deviceId = '',
    this.createdTime,
  });

  String docId;
  HiveMetadataApp? app;
  String deviceId;
  Timestamp? createdTime;

  factory FirebaseUserSession.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc_) {
    final json = doc_.data()!;
    final user = FirebaseUserSession.fromJson(json);
    user.docId = doc_.id;
    return user;
  }

  factory FirebaseUserSession.fromJson(Map<String, dynamic> json) =>
      FirebaseUserSession(
        app: HiveMetadataApp.fromJson(json["app"]),
        deviceId: json["deviceId"],
        createdTime: json["createdTime"],
      );

  Map<String, dynamic> toJson() => {
        "app": app?.toJson(),
        "deviceId": deviceId,
        "createdTime": createdTime,
      };

  static Future<FirebaseUserSession> get() async {
    return FirebaseUserSession(
      app: Globals.metadata!.app,
      deviceId: Globals.metadata!.device.id,
      createdTime: Timestamp.now(),
    );
  }
}
