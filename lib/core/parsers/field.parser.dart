import 'package:flutter/material.dart';
import 'package:liso/core/form_fields/richtext.field.dart';
import 'package:liso/core/form_fields/textarea.field.dart';
import 'package:liso/core/form_fields/textfield.field.dart';

import '../hive/models/field.hive.dart';
import '../form_fields/address.field.dart';
import '../form_fields/coordinates.field.dart';
import '../form_fields/country.field.dart';
import '../form_fields/date.field.dart';
import '../form_fields/datetime.field.dart';
import '../form_fields/divider.field.dart';
import '../form_fields/email.field.dart';
import '../form_fields/gender.field.dart';
import '../form_fields/mnemonic.field.dart';
import '../form_fields/password.field.dart';
import '../form_fields/phone.field.dart';
import '../form_fields/pin.field.dart';
import '../form_fields/section.field.dart';
import '../form_fields/spacer.field.dart';
import '../form_fields/time.field.dart';
import '../form_fields/url.field.dart';

class FieldParser {
  static Widget parse(HiveLisoField field) {
    // SECTION
    if (field.type == LisoFieldType.section.name) {
      return SectionFormField(field);
    }
    // MNEMONIC SEED
    else if (field.type == LisoFieldType.mnemonicSeed.name) {
      return MnemonicFormField(field);
    }
    // TEXT FIELD
    else if (field.type == LisoFieldType.textField.name) {
      return TextFieldForm(field);
    }
    // TEXT AREA
    else if (field.type == LisoFieldType.textArea.name) {
      return TextAreaFormField(field);
    }
    // RICH TEXT
    else if (field.type == LisoFieldType.richText.name) {
      return RichTextFormField(field);
    }
    // ADDRESS
    else if (field.type == LisoFieldType.address.name) {
      return AddressFormField(field);
    }
    // GENDER
    else if (field.type == LisoFieldType.gender.name) {
      return GenderFormField(field);
    }
    // DATE
    else if (field.type == LisoFieldType.date.name) {
      return DateFormField(field);
    }
    // TIME
    else if (field.type == LisoFieldType.time.name) {
      return TimeFormField(field);
    }
    // DATE TIME
    else if (field.type == LisoFieldType.datetime.name) {
      return DateTimeFormField(field);
    }
    // COUNTRY
    else if (field.type == LisoFieldType.country.name) {
      return CountryFormField(field);
    }
    // PHONE
    else if (field.type == LisoFieldType.phone.name) {
      return PhoneFormField(field);
    }
    // EMAIL
    else if (field.type == LisoFieldType.email.name) {
      return EmailFormField(field);
    }
    // URL
    else if (field.type == LisoFieldType.url.name) {
      return URLFormField(field);
    }
    // PASSWORD
    else if (field.type == LisoFieldType.password.name) {
      return PasswordFormField(field);
    }
    // PIN
    else if (field.type == LisoFieldType.pin.name) {
      return PINFormField(field);
    }
    // COORDINATES
    else if (field.type == LisoFieldType.coordinates.name) {
      return CoordinatesFormField(field);
    }
    // DIVIDER
    else if (field.type == LisoFieldType.divider.name) {
      return const DividerFormField();
    }
    // SPACER
    else if (field.type == LisoFieldType.spacer.name) {
      return const SpacerFormField();
    } else {
      throw 'Unknown field type: ${field.type}';
    }
  }
}