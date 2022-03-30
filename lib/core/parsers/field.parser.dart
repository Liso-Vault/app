import 'package:flutter/material.dart';
import 'package:liso/core/parsers/field_parsers/richtext.parser.dart';
import 'package:liso/core/parsers/field_parsers/textarea.parser.dart';
import 'package:liso/core/parsers/field_parsers/textfield.parser.dart';

import '../hive/models/field.hive.dart';
import 'field_parsers/address.parser.dart';
import 'field_parsers/coordinates.parser.dart';
import 'field_parsers/country.parser.dart';
import 'field_parsers/date.parser.dart';
import 'field_parsers/datetime.parser.dart';
import 'field_parsers/divider.parser.dart';
import 'field_parsers/email.parser.dart';
import 'field_parsers/gender.parser.dart';
import 'field_parsers/mnemonic.parser.dart';
import 'field_parsers/password.parser.dart';
import 'field_parsers/phone.parser.dart';
import 'field_parsers/section.parser.dart';
import 'field_parsers/spacer.parser.dart';
import 'field_parsers/time.parser.dart';
import 'field_parsers/url.parser.dart';

class FieldParser {
  static Widget parse(HiveLisoField field) {
    // SECTION
    if (field.type == LisoFieldType.section.name) {
      return SectionFieldParser.parse(field);
    }
    // MNEMONIC SEED
    else if (field.type == LisoFieldType.mnemonicSeed.name) {
      return MnemonicFieldParser.parse(field);
    }
    // TEXT FIELD
    else if (field.type == LisoFieldType.textField.name) {
      return TextFieldParser.parse(field);
    }
    // TEXT AREA
    else if (field.type == LisoFieldType.textArea.name) {
      return TextAreaFieldParser.parse(field);
    }
    // RICH TEXT
    else if (field.type == LisoFieldType.richText.name) {
      return RichTextFieldParser.parse(field);
    }
    // ADDRESS
    else if (field.type == LisoFieldType.address.name) {
      return AddressFieldParser.parse(field);
    }
    // GENDER
    else if (field.type == LisoFieldType.gender.name) {
      return GenderFieldParser.parse(field);
    }
    // DATE
    else if (field.type == LisoFieldType.date.name) {
      return DateFieldParser.parse(field);
    }
    // TIME
    else if (field.type == LisoFieldType.time.name) {
      return TimeFieldParser.parse(field);
    }
    // DATE TIME
    else if (field.type == LisoFieldType.datetime.name) {
      return DateTimeFieldParser.parse(field);
    }
    // COUNTRY
    else if (field.type == LisoFieldType.country.name) {
      return CountryFieldParser.parse(field);
    }
    // PHONE
    else if (field.type == LisoFieldType.phone.name) {
      return PhoneFieldParser.parse(field);
    }
    // EMAIL
    else if (field.type == LisoFieldType.email.name) {
      return EmailFieldParser.parse(field);
    }
    // URL
    else if (field.type == LisoFieldType.url.name) {
      return URLFieldParser.parse(field);
    }
    // PASSWORD
    else if (field.type == LisoFieldType.password.name) {
      return PasswordFieldParser.parse(field);
    }
    // COORDINATES
    else if (field.type == LisoFieldType.coordinates.name) {
      return CoordinatesFieldParser.parse(field);
    }
    // DIVIDER
    else if (field.type == LisoFieldType.divider.name) {
      return DividerFieldParser.parse(field);
    }
    // SPACER
    else if (field.type == LisoFieldType.spacer.name) {
      return SpacerFieldParser.parse(field);
    } else {
      throw 'Unknown field type: ${field.type}';
    }
  }
}
