import 'package:liso/core/form_fields/choices.field.dart';
import 'package:liso/core/form_fields/date.field.dart';
import 'package:liso/core/form_fields/password.field.dart';
import 'package:liso/core/form_fields/phone.field.dart';
import 'package:liso/core/form_fields/pin.field.dart';
import 'package:liso/core/form_fields/richtext.field.dart';
import 'package:liso/core/form_fields/seed.field.dart';
import 'package:liso/core/form_fields/textarea.field.dart';
import 'package:liso/core/form_fields/textfield.field.dart';
import 'package:liso/core/form_fields/url.field.dart';

import '../form_fields/address.field.dart';
import '../form_fields/email.field.dart';
import '../form_fields/number.field.dart';
import '../form_fields/passport.field.dart';
import '../hive/models/field.hive.dart';
import '../hive/models/item.hive.dart';

class FormFieldUtils {
  static List<HiveLisoField> obtainFields(
    HiveLisoItem item, {
    required List<dynamic> widgets,
  }) {
    final List<HiveLisoField> newFields = [];

    for (var i = 0; i < item.fields.length; i++) {
      final field = item.fields[i];
      dynamic widget = widgets[i].children.first.child;
      dynamic formField;

      switch (LisoFieldType.values.byName(field.type)) {
        case LisoFieldType.choices:
          formField = widget as ChoicesFormField;
          break;
        case LisoFieldType.textField:
          formField = widget as TextFieldForm;
          break;
        case LisoFieldType.textArea:
          formField = widget as TextAreaFormField;
          break;
        case LisoFieldType.richText:
          formField = widget as RichTextFormField;
          break;
        case LisoFieldType.password:
          formField = widget as PasswordFormField;
          break;
        case LisoFieldType.url:
          formField = widget as URLFormField;
          break;
        case LisoFieldType.email:
          formField = widget as EmailFormField;
          break;
        case LisoFieldType.date:
          formField = widget as DateFormField;
          break;
        case LisoFieldType.phone:
          formField = widget as PhoneFormField;
          break;
        case LisoFieldType.pin:
          formField = widget as PINFormField;
          break;
        case LisoFieldType.number:
          formField = widget as NumberFormField;
          break;
        case LisoFieldType.passport:
          formField = widget as PassportFormField;
          break;
        case LisoFieldType.address:
          formField = widget as AddressFormField;
          break;
        case LisoFieldType.mnemonicSeed:
          formField = widget as SeedFormField;
          break;
        default:
      }

      if (formField != null) {
        if (formField.value is Map<String, dynamic>) {
          field.data.extra = formField.value;
        } else {
          field.data.value = formField.value ?? '';
        }
      }

      newFields.add(field);
    }

    return newFields;
  }
}
