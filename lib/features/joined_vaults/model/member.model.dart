import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';

import '../../../core/utils/globals.dart';

class VaultMember {
  const VaultMember({
    this.docId = '',
    this.userId = '',
    this.address = '',
    this.permissions = '',
    this.createdTime,
    this.updatedTime,
    this.metadata,
  });

  final String docId;
  final String userId;
  final String address;
  final String permissions;
  final Timestamp? createdTime;
  final Timestamp? updatedTime;
  final HiveMetadata? metadata;

  factory VaultMember.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc_) {
    final json = doc_.data()!;

    return VaultMember(
      docId: doc_.id,
      userId: json["userId"],
      address: json["address"],
      permissions: json["permissions"],
      createdTime: json["createdTime"],
      updatedTime: json["updatedTime"],
      metadata: HiveMetadata.fromJson(json["metadata"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "address": address,
      "permissions": permissions,
      if (createdTime == null) "createdTime": FieldValue.serverTimestamp(),
      "updatedTime": FieldValue.serverTimestamp(),
      "metadata": Globals.metadata.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
