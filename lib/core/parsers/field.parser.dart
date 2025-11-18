import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/form_fields/choices.field.dart';
import 'package:liso/core/form_fields/richtext.field.dart';
import 'package:liso/core/form_fields/slider.field.dart';
import 'package:liso/core/form_fields/textarea.field.dart';
import 'package:liso/core/form_fields/textfield.field.dart';
import 'package:liso/core/form_fields/toggle.field.dart';
import 'package:liso/core/form_fields/totp.field.dart';
import 'package:secrets/secrets_old.dart';

import '../form_fields/address.field.dart';
import '../form_fields/coordinates.field.dart';
import '../form_fields/date.field.dart';
import '../form_fields/datetime.field.dart';
import '../form_fields/divider.field.dart';
import '../form_fields/email.field.dart';
import '../form_fields/number.field.dart';
import '../form_fields/passport.field.dart';
import '../form_fields/password.field.dart';
import '../form_fields/phone.field.dart';
import '../form_fields/pin.field.dart';
import '../form_fields/section.field.dart';
import '../form_fields/seed.field.dart';
import '../form_fields/spacer.field.dart';
import '../form_fields/time.field.dart';
import '../form_fields/url.field.dart';
import '../hive/models/field.hive.dart';

class FieldParser {
  static Widget parse(HiveLisoField field) {
    // SECTION
    if (field.type == LisoFieldType.section.name) {
      return SectionFormField(field);
    }
    // CHOICES
    else if (field.type == LisoFieldType.choices.name) {
      return ChoicesFormField(field);
    }
    // MNEMONIC SEED
    else if (field.type == LisoFieldType.mnemonicSeed.name) {
      return SeedFormField(field);
    }
    // TEXT FIELD
    else if (field.type == LisoFieldType.textField.name) {
      return TextFieldForm(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // TEXT AREA
    else if (field.type == LisoFieldType.textArea.name) {
      return TextAreaFormField(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // RICH TEXT
    else if (field.type == LisoFieldType.richText.name) {
      return RichTextFormField(field);
    }
    // ADDRESS
    else if (field.type == LisoFieldType.address.name) {
      final extra = field.data.extra!;

      return AddressFormField(
        field,
        street1Controller: TextEditingController(text: extra['street1']),
        street2Controller: TextEditingController(text: extra['street2']),
        cityController: TextEditingController(text: extra['city']),
        stateController: TextEditingController(text: extra['state']),
        zipController: TextEditingController(text: extra['zip']),
        countryFormField: ChoicesFormField(
          HiveLisoField(
            type: LisoFieldType.choices.name,
            readOnly: field.readOnly,
            data: HiveLisoFieldData(
              value: extra['country'],
              label: 'Country',
              choices: List<HiveLisoFieldChoices>.from(
                Secrets.countries.map((x) => HiveLisoFieldChoices.fromJson(x)),
              ),
            ),
          ),
        ),
      );
    }
    // DATE
    else if (field.type == LisoFieldType.date.name) {
      DateTime? initialDate;

      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(field.data.value!);
      } catch (e) {
        // empty date
      }

      return DateFormField(
        field,
        initialDate: initialDate,
        fieldController: TextEditingController(
          text: initialDate != null
              ? DateFormat('dd/MM/yyyy').format(initialDate)
              : '',
        ),
      );
    }
    // TIME
    else if (field.type == LisoFieldType.time.name) {
      return TimeFormField(field);
    }
    // DATE TIME
    else if (field.type == LisoFieldType.datetime.name) {
      return DateTimeFormField(field);
    }
    // PHONE
    else if (field.type == LisoFieldType.phone.name) {
      return PhoneFormField(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // EMAIL
    else if (field.type == LisoFieldType.email.name) {
      return EmailFormField(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // URL
    else if (field.type == LisoFieldType.url.name) {
      return URLFormField(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // PASSWORD
    else if (field.type == LisoFieldType.password.name) {
      return PasswordFormField(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // PIN
    else if (field.type == LisoFieldType.pin.name) {
      return PINFormField(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // TOTP
    else if (field.type == LisoFieldType.totp.name) {
      return TOTPFormField(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // NUMBER
    else if (field.type == LisoFieldType.number.name) {
      return NumberFormField(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // PASSPORT
    else if (field.type == LisoFieldType.passport.name) {
      return PassportFormField(
        field,
        fieldController: TextEditingController(text: field.data.value),
      );
    }
    // TOGGLE
    else if (field.type == LisoFieldType.toggle.name) {
      return ToggleFieldForm(field);
    }
    // SLIDER
    else if (field.type == LisoFieldType.slider.name) {
      return SliderFieldForm(field);
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
      throw 'Unknown field type';
    }
  }
}
