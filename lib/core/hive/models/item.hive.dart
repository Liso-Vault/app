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
import 'package:supercharged/supercharged.dart';

import '../../utils/utils.dart';
import 'field.hive.dart';
import 'metadata/metadata.hive.dart';

part 'item.hive.g.dart';

@HiveType(typeId: 1)
class HiveLisoItem extends HiveObject with EquatableMixin, ConsoleMixin {
  @HiveField(0)
  final String identifier;
  @HiveField(1)
  final String category;
  @HiveField(2)
  String title;
  @HiveField(3)
  String iconUrl;
  @HiveField(4)
  List<HiveLisoField> fields;
  @HiveField(5)
  bool favorite;
  @HiveField(6)
  bool protected;
  @HiveField(7)
  bool trashed;
  @HiveField(8)
  List<String> tags;
  @HiveField(9)
  HiveMetadata metadata;
  @HiveField(10)
  int group;

  HiveLisoItem({
    required this.identifier,
    required this.category,
    required this.title,
    this.iconUrl = '',
    required this.fields,
    this.favorite = false,
    this.protected = false,
    this.trashed = false,
    this.tags = const [],
    required this.metadata,
    required this.group,
  });

  factory HiveLisoItem.fromJson(Map<String, dynamic> json) => HiveLisoItem(
        identifier: json["identifier"],
        category: json["category"],
        iconUrl: json["icon_url"],
        title: json["title"],
        fields: json["fields"],
        favorite: json["favorite"],
        protected: json["protected"],
        trashed: json["trashed"],
        tags: json["tags"],
        metadata: HiveMetadata.fromJson(json["metadata"]),
        group: json["group"],
      );

  Map<String, dynamic> toJson() {
    return {
      "identifier": identifier,
      "category": category,
      "icon_url": iconUrl,
      "title": title,
      "fields": List<dynamic>.from(fields.map((x) => x.toJson())),
      "favorite": favorite,
      "protected": protected,
      "trashed": trashed,
      "tags": tags,
      "metadata": metadata.toJson(),
      "group": group,
    };
  }

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
      10;

  LisoItemCategory get categoryObject =>
      LisoItemCategory.values.byName(category);

  String get subTitle {
    String _identifier = '';

    switch (categoryObject) {
      case LisoItemCategory.cryptoWallet:
        _identifier = 'address';
        break;
      case LisoItemCategory.login:
        _identifier = 'website';
        break;
      case LisoItemCategory.password:
        _identifier = 'website';
        break;
      case LisoItemCategory.identity:
        _identifier = 'first_name';
        break;
      case LisoItemCategory.note:
        _identifier = 'note';
        break;
      case LisoItemCategory.cashCard:
        _identifier = 'holder_name';
        break;
      case LisoItemCategory.bankAccount:
        _identifier = 'account_name';
        break;
      case LisoItemCategory.medicalRecord:
        _identifier = 'healthcare_professional';
        break;
      case LisoItemCategory.passport:
        _identifier = 'full_name';
        break;
      case LisoItemCategory.server:
        _identifier = 'url';
        break;
      case LisoItemCategory.softwareLicense:
        _identifier = 'publisher';
        break;
      case LisoItemCategory.apiCredential:
        _identifier = 'host_name';
        break;
      case LisoItemCategory.database:
        _identifier = 'database';
        break;
      case LisoItemCategory.driversLicense:
        _identifier = 'full_name';
        break;
      case LisoItemCategory.email:
        _identifier = 'username';
        break;
      case LisoItemCategory.membership:
        _identifier = 'website';
        break;
      case LisoItemCategory.outdoorLicense:
        _identifier = 'approved_wildlife';
        break;
      case LisoItemCategory.rewardsProgram:
        _identifier = 'company_name';
        break;
      case LisoItemCategory.socialSecurity:
        _identifier = 'name';
        break;
      case LisoItemCategory.wirelessRouter:
        _identifier = 'base_station_name';
        break;
      case LisoItemCategory.encryption:
        _identifier = 'note';
        break;
      default:
        throw 'item identifier: $_identifier not found while obtaining sub title';
    }

    final _field = fields.firstWhere((e) => e.identifier == _identifier);
    String _value = _field.data.value!;

    // decode rich text back to plain text
    if (categoryObject == LisoItemCategory.note) {
      try {
        _value = Document.fromJson(jsonDecode(_value)).toPlainText();
      } catch (e) {
        console.error('error decoding rich text: $e');
        _value = 'failed to decode';
      }
    }

    return _value;
  }

  // TODO: bind corresponding significant data
  Map<String, String> get significant {
    String _identifier = '';

    switch (categoryObject) {
      case LisoItemCategory.cryptoWallet:
        _identifier = 'address';
        break;
      case LisoItemCategory.login:
        _identifier = 'website';
        break;
      case LisoItemCategory.password:
        _identifier = 'website';
        break;
      case LisoItemCategory.identity:
        _identifier = 'first_name';
        break;
      case LisoItemCategory.note:
        _identifier = 'note';
        break;
      case LisoItemCategory.cashCard:
        _identifier = 'note';
        break;
      case LisoItemCategory.bankAccount:
        _identifier = 'note';
        break;
      case LisoItemCategory.medicalRecord:
        _identifier = 'note';
        break;
      case LisoItemCategory.passport:
        _identifier = 'full_name';
        break;
      case LisoItemCategory.server:
        _identifier = 'url';
        break;
      case LisoItemCategory.softwareLicense:
        _identifier = 'publisher';
        break;
      case LisoItemCategory.apiCredential:
        _identifier = 'note';
        break;
      case LisoItemCategory.database:
        _identifier = 'note';
        break;
      case LisoItemCategory.driversLicense:
        _identifier = 'note';
        break;
      case LisoItemCategory.email:
        _identifier = 'username';
        break;
      case LisoItemCategory.membership:
        _identifier = 'group';
        break;
      case LisoItemCategory.outdoorLicense:
        _identifier = 'note';
        break;
      case LisoItemCategory.rewardsProgram:
        _identifier = 'note';
        break;
      case LisoItemCategory.socialSecurity:
        _identifier = 'name';
        break;
      case LisoItemCategory.wirelessRouter:
        _identifier = 'note';
        break;
      case LisoItemCategory.encryption:
        _identifier = 'note';
        break;
      default:
        throw 'item identifier: $_identifier not found while obtaining sub title';
    }

    final _field = fields.firstWhere((e) => e.identifier == _identifier);
    // convert Map keys to human readable format
    _identifier = GetUtils.capitalize(_identifier.replaceAll('_', ' '))!;
    var _value = _field.data.value!;

    // decode rich text back to plain text
    if (categoryObject == LisoItemCategory.note) {
      try {
        _value = Document.fromJson(jsonDecode(_value)).toPlainText();
      } catch (e) {
        console.error('error decoding rich text: $e');
        _value = 'failed to decode';
      }
    }

    return {_identifier: _value};
  }

  @override
  List<Object?> get props => [identifier, metadata.updatedTime];
}
