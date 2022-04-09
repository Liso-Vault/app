import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';

import '../../utils/utils.dart';
import 'field.hive.dart';
import 'metadata/metadata.hive.dart';

part 'item.hive.g.dart';

@HiveType(typeId: 1)
class HiveLisoItem extends HiveObject with ConsoleMixin {
  @HiveField(0)
  String category;
  @HiveField(1)
  Uint8List icon;
  @HiveField(2)
  String title;
  @HiveField(3)
  List<HiveLisoField> fields;
  @HiveField(4)
  bool favorite;
  @HiveField(5)
  bool protected;
  @HiveField(6)
  List<String> tags;
  @HiveField(7)
  HiveMetadata metadata;

  HiveLisoItem({
    required this.category,
    required this.icon,
    required this.title,
    required this.fields,
    this.favorite = false,
    this.protected = false,
    this.tags = const [],
    required this.metadata,
  });

  factory HiveLisoItem.fromJson(Map<String, dynamic> json) => HiveLisoItem(
        category: json["category"],
        icon: json["icon"],
        title: json["title"],
        fields: json["fields"],
        favorite: json["favorite"],
        protected: json["protected"],
        tags: json["tags"],
        metadata: HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "category": category,
      "icon": icon,
      "title": title,
      "fields": List<dynamic>.from(fields.map((x) => x.toJson())),
      "favorite": favorite,
      "protected": protected,
      "tags": tags,
      "metadata": metadata.toJson(),
    };
  }

  List<Widget> get widgets => fields.map((e) => e.widget).toList();

  String get updatedDateTimeFormatted =>
      DateFormat.yMMMMd().add_jm().format(metadata.updatedTime);

  String get createdDateTimeFormatted =>
      DateFormat.yMMMMd().add_jm().format(metadata.createdTime);

  String get updatedTimeAgo =>
      Utils.timeAgo(metadata.updatedTime, short: false);

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
        _identifier = 'note';
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
        _identifier = 'email';
        break;
      case LisoItemCategory.membership:
        _identifier = 'note';
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
    String _value = _field.data['value'];

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
        _identifier = 'note';
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
        _identifier = 'email';
        break;
      case LisoItemCategory.membership:
        _identifier = 'note';
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

    String _value = _field.data['value'];

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
}
