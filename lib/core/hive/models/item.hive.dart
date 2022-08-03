import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/hive/models/app_domain.hive.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:supercharged/supercharged.dart';

import '../../../features/pro/pro.controller.dart';
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
  String category;
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
  // // needs migration if index is re-ordered
  @HiveField(16)
  List<HiveDomain>? domains;
  @HiveField(17)
  List<String>? appIds;

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
    this.domains = const [],
    this.appIds = const [],
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
        domains: json["domains"] == null
            ? []
            : List<HiveDomain>.from(
                json["domains"].map((x) => HiveDomain.fromJson(x)),
              ),
        appIds: json["app_ids"] == null
            ? []
            : List<String>.from(json["app_ids"].map((x) => x)),
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
      "domains": domains == null
          ? []
          : List<dynamic>.from(domains!.map((x) => x.toJson())),
      "app_ids": appIds == null ? [] : List<dynamic>.from(tags.map((x) => x)),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  bool get hasWeakPasswords {
    final passwords = fields.where((e) {
      if (e.type != LisoFieldType.password.name) return false;
      if (e.data.value!.isEmpty) return false;
      // if not a password field
      if (kNonPasswordFieldIds.contains(e.identifier)) return false;
      final strength = PasswordStrengthChecker.checkStrength(e.data.value!);
      return strength != PasswordStrength.STRONG;
    });

    return passwords.isNotEmpty;
  }

  bool get hasReusedPasswords {
    final passwords = fields.where((e) {
      if (e.type != LisoFieldType.password.name) return false;
      if (e.data.value!.isEmpty) return false;
      // if not a password field
      if (kNonPasswordFieldIds.contains(e.identifier)) return false;
      // TODO: work on detecting re-used passwords
      return false;
    });

    return passwords.isNotEmpty;
  }

  bool get hasOldPasswords {
    final passwords = fields.where((e) {
      if (e.type != LisoFieldType.password.name) return false;
      if (e.data.value!.isEmpty) return false;
      // if not a password field
      if (kNonPasswordFieldIds.contains(e.identifier)) return false;
      // TODO: work on detecting old passwords
      return false;
    });

    return passwords.isNotEmpty;
  }

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
        appIds,
        domains,
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
      ProController.to.limits.trashDays;

  String get subTitle {
    String identifier = significant.keys.first;
    final field = fields.firstWhere((e) => e.identifier == identifier);
    final value = field.data.value ?? '';

    // obscure characters
    if (category == LisoItemCategory.encryption.name ||
        category == LisoItemCategory.note.name) {
      return '';
    }

    return value;
  }

  List<HiveLisoField> get usernameFields {
    return fields.where((e) {
      if (e.data.value!.isEmpty) return false;
      if (e.type != LisoFieldType.textField.name &&
          e.type != LisoFieldType.phone.name &&
          e.type != LisoFieldType.email.name) return false;

      final isUsername = (e.type == LisoFieldType.textField.name &&
          (e.identifier == 'username' ||
              e.data.label!.toLowerCase().contains('username')));

      if (e.type == LisoFieldType.email.name ||
          e.type == LisoFieldType.phone.name ||
          isUsername) {
        return true;
      }

      if (GetUtils.isEmail(e.data.value!) ||
          GetUtils.isPhoneNumber(e.data.value!)) return true;

      return false;
    }).toList();
  }

  List<HiveLisoField> get passwordFields {
    return fields.where((e) {
      if (e.type != LisoFieldType.password.name) return false;
      if (e.data.value!.isEmpty) return false;
      // if not a password field
      if (kNonPasswordFieldIds.contains(e.identifier)) return false;
      return true;
    }).toList();
  }

  // TODO: bind corresponding significant data
  Map<String, String> get significant {
    String identifier = '';

    if (category == LisoItemCategory.cryptoWallet.name) {
      identifier = 'address';
    } else if (category == LisoItemCategory.login.name) {
      identifier = 'website';
    } else if (category == LisoItemCategory.password.name) {
      identifier = 'website';
    } else if (category == LisoItemCategory.identity.name) {
      identifier = 'first_name';
    } else if (category == LisoItemCategory.note.name) {
      identifier = 'note';
    } else if (category == LisoItemCategory.cashCard.name) {
      identifier = 'holder_name';
    } else if (category == LisoItemCategory.bankAccount.name) {
      identifier = 'account_name';
    } else if (category == LisoItemCategory.medicalRecord.name) {
      identifier = 'healthcare_professional';
    } else if (category == LisoItemCategory.passport.name) {
      identifier = 'full_name';
    } else if (category == LisoItemCategory.server.name) {
      identifier = 'url';
    } else if (category == LisoItemCategory.softwareLicense.name) {
      identifier = 'publisher';
    } else if (category == LisoItemCategory.apiCredential.name) {
      identifier = 'host_name';
    } else if (category == LisoItemCategory.database.name) {
      identifier = 'database';
    } else if (category == LisoItemCategory.driversLicense.name) {
      identifier = 'full_name';
    } else if (category == LisoItemCategory.email.name) {
      identifier = 'username';
    } else if (category == LisoItemCategory.membership.name) {
      identifier = 'website';
    } else if (category == LisoItemCategory.outdoorLicense.name) {
      identifier = 'approved_wildlife';
    } else if (category == LisoItemCategory.rewardsProgram.name) {
      identifier = 'company_name';
    } else if (category == LisoItemCategory.socialSecurity.name) {
      identifier = 'name';
    } else if (category == LisoItemCategory.wirelessRouter.name) {
      identifier = 'base_station_name';
    } else if (category == LisoItemCategory.encryption.name) {
      identifier = 'note';
    } else {
      identifier = 'note';
    }

    final foundFields = fields.where((e) => e.identifier == identifier);
    var field = foundFields.isNotEmpty ? foundFields.first : null;

    // if modified category
    if (field == null || field.data.value == null) {
      identifier = 'note';
      field = fields.firstWhere((e) => e.identifier == identifier);
    }

    String value = field.data.value ?? '';

    return {
      identifier: value,
      'name': GetUtils.capitalize(identifier.replaceAll('_', ' '))!,
    };
  }
}
