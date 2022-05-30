import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:supercharged/supercharged.dart';

import '../../utils/utils.dart';
import 'field.hive.dart';
import 'metadata/metadata.hive.dart';

part 'item.hive.g.dart';

@HiveType(typeId: 0)
class HiveLisoItem extends HiveObject with EquatableMixin, ConsoleMixin {
  @HiveField(0)
  String identifier;
  @HiveField(1)
  String groupId;
  @HiveField(2)
  final String category;
  @HiveField(3)
  String title;
  @HiveField(4)
  String iconUrl;
  @HiveField(5)
  List<HiveLisoField> fields;
  @HiveField(6)
  bool favorite;
  @HiveField(7)
  bool protected;
  @HiveField(8)
  bool trashed;
  @HiveField(9)
  bool deleted;
  @HiveField(10)
  bool reserved;
  @HiveField(11)
  bool hidden;
  @HiveField(12)
  List<String> tags;
  @HiveField(13)
  List<String> sharedVaultIds;
  @HiveField(14)
  List<String> attachments;
  @HiveField(15)
  HiveMetadata metadata;

  HiveLisoItem({
    required this.identifier,
    required this.groupId,
    required this.category,
    required this.title,
    this.iconUrl = '',
    required this.fields,
    this.favorite = false,
    this.protected = false,
    this.trashed = false,
    this.deleted = false,
    this.reserved = false,
    this.hidden = false,
    this.tags = const [],
    this.sharedVaultIds = const [],
    this.attachments = const [],
    required this.metadata,
  });

  factory HiveLisoItem.fromJson(Map<String, dynamic> json) => HiveLisoItem(
        identifier: json["identifier"],
        groupId: json["group_id"],
        category: json["category"],
        iconUrl: json["icon_url"],
        title: json["title"],
        fields: List<HiveLisoField>.from(
          json["fields"].map((x) => HiveLisoField.fromJson(x)),
        ),
        favorite: json["favorite"],
        protected: json["protected"],
        trashed: json["trashed"],
        deleted: json["deleted"],
        reserved: json["reserved"],
        hidden: json["hidden"],
        tags: List<String>.from(json["tags"].map((x) => x)),
        sharedVaultIds:
            List<String>.from(json["shared_vault_ids"].map((x) => x)),
        attachments: List<String>.from(json["attachments"].map((x) => x)),
        metadata: HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "identifier": identifier,
      "group_id": groupId,
      "category": category,
      "icon_url": iconUrl,
      "title": title,
      "fields": List<dynamic>.from(fields.map((x) => x.toJson())),
      "favorite": favorite,
      "protected": protected,
      "trashed": trashed,
      "deleted": deleted,
      "reserved": reserved,
      "hidden": hidden,
      "tags": List<dynamic>.from(tags.map((x) => x)),
      "shared_vault_ids": List<dynamic>.from(sharedVaultIds.map((x) => x)),
      "attachments": List<dynamic>.from(attachments.map((x) => x)),
      "metadata": metadata.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [
        identifier,
        groupId,
        category,
        iconUrl,
        title,
        fields,
        favorite,
        protected,
        trashed,
        deleted,
        reserved,
        hidden,
        tags,
        sharedVaultIds,
        attachments,
        metadata,
      ];

  List<Widget> get widgets => fields.map((e) => e.widget).toList();

  String get updatedDateTimeFormatted =>
      DateFormat.yMMMMd().add_jm().format(metadata.updatedTime);

  String get createdDateTimeFormatted =>
      DateFormat.yMMMMd().add_jm().format(metadata.createdTime);

  String get updatedTimeAgo =>
      Utils.timeAgo(metadata.updatedTime, short: false);

  int get daysLeftToDelete =>
      metadata.updatedTime.duration().inDays -
      DateTime.now().duration().inDays +
      WalletService.to.limits.trashDays;

  LisoItemCategory get categoryObject =>
      LisoItemCategory.values.byName(category);

  String get subTitle {
    String identifier = '';

    switch (categoryObject) {
      case LisoItemCategory.cryptoWallet:
        identifier = 'address';
        break;
      case LisoItemCategory.login:
        identifier = 'website';
        break;
      case LisoItemCategory.password:
        identifier = 'website';
        break;
      case LisoItemCategory.identity:
        identifier = 'first_name';
        break;
      case LisoItemCategory.note:
        identifier = 'note';
        break;
      case LisoItemCategory.cashCard:
        identifier = 'holder_name';
        break;
      case LisoItemCategory.bankAccount:
        identifier = 'account_name';
        break;
      case LisoItemCategory.medicalRecord:
        identifier = 'healthcare_professional';
        break;
      case LisoItemCategory.passport:
        identifier = 'full_name';
        break;
      case LisoItemCategory.server:
        identifier = 'url';
        break;
      case LisoItemCategory.softwareLicense:
        identifier = 'publisher';
        break;
      case LisoItemCategory.apiCredential:
        identifier = 'host_name';
        break;
      case LisoItemCategory.database:
        identifier = 'database';
        break;
      case LisoItemCategory.driversLicense:
        identifier = 'full_name';
        break;
      case LisoItemCategory.email:
        identifier = 'username';
        break;
      case LisoItemCategory.membership:
        identifier = 'website';
        break;
      case LisoItemCategory.outdoorLicense:
        identifier = 'approved_wildlife';
        break;
      case LisoItemCategory.rewardsProgram:
        identifier = 'company_name';
        break;
      case LisoItemCategory.socialSecurity:
        identifier = 'name';
        break;
      case LisoItemCategory.wirelessRouter:
        identifier = 'base_station_name';
        break;
      case LisoItemCategory.encryption:
        identifier = 'note';
        break;
      default:
        throw 'item identifier: $identifier not found while obtaining sub title';
    }

    final field = fields.firstWhere((e) => e.identifier == identifier);
    if (field.data.value == null) console.error('null value here');
    String value = field.data.value ?? '';

    // // decode rich text back to plain text
    // if (categoryObject == LisoItemCategory.note) {
    //   try {
    //     value = Document.fromJson(jsonDecode(value)).toPlainText();
    //   } catch (e) {
    //     console.error('error decoding rich text: $e');
    //     value = 'failed to decode';
    //   }
    // }

    // obscure characters
    if (categoryObject == LisoItemCategory.encryption ||
        categoryObject == LisoItemCategory.note) {
      final obscuredCharacters = <String>[];

      for (var i = 0; i < (value.length < 100 ? value.length : 100); i++) {
        obscuredCharacters.add('*');
      }

      return obscuredCharacters.join();
    }

    return value;
  }

  // TODO: bind corresponding significant data
  Map<String, String> get significant {
    String identifier = '';

    switch (categoryObject) {
      case LisoItemCategory.cryptoWallet:
        identifier = 'address';
        break;
      case LisoItemCategory.login:
        identifier = 'website';
        break;
      case LisoItemCategory.password:
        identifier = 'website';
        break;
      case LisoItemCategory.identity:
        identifier = 'first_name';
        break;
      case LisoItemCategory.note:
        identifier = 'note';
        break;
      case LisoItemCategory.cashCard:
        identifier = 'note';
        break;
      case LisoItemCategory.bankAccount:
        identifier = 'note';
        break;
      case LisoItemCategory.medicalRecord:
        identifier = 'note';
        break;
      case LisoItemCategory.passport:
        identifier = 'full_name';
        break;
      case LisoItemCategory.server:
        identifier = 'url';
        break;
      case LisoItemCategory.softwareLicense:
        identifier = 'publisher';
        break;
      case LisoItemCategory.apiCredential:
        identifier = 'note';
        break;
      case LisoItemCategory.database:
        identifier = 'note';
        break;
      case LisoItemCategory.driversLicense:
        identifier = 'note';
        break;
      case LisoItemCategory.email:
        identifier = 'username';
        break;
      case LisoItemCategory.membership:
        identifier = 'group';
        break;
      case LisoItemCategory.outdoorLicense:
        identifier = 'note';
        break;
      case LisoItemCategory.rewardsProgram:
        identifier = 'note';
        break;
      case LisoItemCategory.socialSecurity:
        identifier = 'name';
        break;
      case LisoItemCategory.wirelessRouter:
        identifier = 'note';
        break;
      case LisoItemCategory.encryption:
        identifier = 'note';
        break;
      default:
        throw 'item identifier: $identifier not found while obtaining sub title';
    }

    final field = fields.firstWhere((e) => e.identifier == identifier);
    // convert Map keys to human readable format
    identifier = GetUtils.capitalize(identifier.replaceAll('_', ' '))!;
    if (field.data.value == null) console.error('null value here');
    var value = field.data.value ?? '';

    // decode rich text back to plain text
    if (categoryObject == LisoItemCategory.note) {
      try {
        value = Document.fromJson(jsonDecode(value)).toPlainText();
      } catch (e) {
        console.error('error decoding rich text: $e');
        value = 'failed to decode';
      }
    }

    return {identifier: value};
  }
}
