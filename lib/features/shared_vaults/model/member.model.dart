import 'package:cloud_firestore/cloud_firestore.dart';

class VaultMember {
  const VaultMember({
    this.docId = '',
    this.userId = '',
    this.address = '',
    this.createdTime,
    this.updatedTime,
  });

  final String docId;
  final String userId;
  final String address;
  final Timestamp? createdTime;
  final Timestamp? updatedTime;

  factory VaultMember.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc_) {
    final json = doc_.data()!;

    return VaultMember(
      docId: doc_.id,
      userId: json["userId"],
      address: json["address"],
      createdTime: json["createdTime"],
      updatedTime: json["updatedTime"],
    );
  }

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "address": address,
        if (createdTime == null) "createdTime": FieldValue.serverTimestamp(),
        "updatedTime": FieldValue.serverTimestamp(),
      };
}
