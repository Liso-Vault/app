import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liso/core/firebase/auth.service.dart';

class SharedVault {
  const SharedVault({
    this.docId = '',
    this.userId = '',
    this.name = '',
    this.description = '',
    this.address = '',
    this.iconUrl = '',
    this.createdTime,
    this.updatedTime,
    this.enabled = true,
  });

  final String docId;
  final String userId;
  final String name;
  final String description;
  final String address;
  final String iconUrl;
  final Timestamp? createdTime;
  final Timestamp? updatedTime;
  final bool enabled;

  factory SharedVault.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc_) {
    final json = doc_.data()!;

    return SharedVault(
      docId: doc_.id,
      userId: json["userId"],
      name: json["name"],
      description: json["description"],
      address: json["address"],
      iconUrl: json["iconUrl"],
      createdTime: json["createdTime"],
      updatedTime: json["updatedTime"],
      enabled: json["enabled"],
    );
  }

  Map<String, dynamic> toFirestoreJson() => {
        "userId": userId,
        "name": name,
        "description": description,
        "address": address,
        "iconUrl": iconUrl,
        if (createdTime == null) "createdTime": FieldValue.serverTimestamp(),
        "updatedTime": FieldValue.serverTimestamp(),
        "enabled": enabled,
      };

  bool get isOwner => userId == AuthService.to.userId;
}
