import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../parsers/field.parser.dart';

part 'field.hive.g.dart';

@HiveType(typeId: 2)
class HiveLisoField extends HiveObject {
  @HiveField(0)
  final String type; // type of field to parse
  @HiveField(1)
  final bool reserved; // if the user can remove the field or not
  @HiveField(2)
  Map<String, dynamic> data; // map that holds the value and/or parameters

  HiveLisoField({
    required this.type,
    this.reserved = false,
    this.data = const {},
  });

  factory HiveLisoField.fromJson(Map<String, dynamic> json) => HiveLisoField(
        type: json["type"],
        reserved: json["reserved"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "reserved": reserved,
      "data": data,
    };
  }

  Widget get widget => FieldParser.parse(this);
}

enum LisoFieldType {
  section,
  mnemonicSeed, // {seed, privateKey, address, dlt, origin}
  textField,
  textArea,
  richText,
  address, // {street1, street2, city, state, zip, country}
  gender,
  date,
  time, // {timezone}
  datetime, // {timezone}
  country,
  phone, // {country code, postfix}
  email,
  url,
  password,
  pin,
  coordinates, // {latitude, longitude}
  divider,
  spacer,
  tags,
}