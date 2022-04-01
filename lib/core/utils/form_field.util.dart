import 'package:flutter/widgets.dart';
import 'package:liso/core/form_fields/password.field.dart';
import 'package:liso/core/form_fields/phone.field.dart';
import 'package:liso/core/form_fields/pin.field.dart';
import 'package:liso/core/form_fields/richtext.field.dart';
import 'package:liso/core/form_fields/textarea.field.dart';
import 'package:liso/core/form_fields/textfield.field.dart';
import 'package:liso/core/form_fields/url.field.dart';

import '../form_fields/email.field.dart';
import '../hive/models/field.hive.dart';
import '../hive/models/item.hive.dart';
import '../form_fields/address.field.dart';
import '../form_fields/country.field.dart';
import '../form_fields/gender.field.dart';

class FormFieldUtils {
  static List<HiveLisoField> obtainFields(
    HiveLisoItem item, {
    required List<Widget> widgets,
  }) {
    // final console = Console(name: 'FormFieldUtils');
    final List<HiveLisoField> _newFields = [];

    for (var i = 0; i < item.fields.length; i++) {
      final _field = item.fields[i];
      final _widget = widgets[i];
      final _fieldType = LisoFieldType.values.byName(_field.type);

      dynamic formField;

      switch (_fieldType) {
        case LisoFieldType.textField:
          formField = _widget as TextFieldForm;
          break;
        case LisoFieldType.textArea:
          formField = _widget as TextAreaFormField;
          break;
        case LisoFieldType.richText:
          formField = _widget as RichTextFormField;
          break;
        case LisoFieldType.password:
          formField = _widget as PasswordFormField;
          break;
        case LisoFieldType.url:
          formField = _widget as URLFormField;
          break;
        case LisoFieldType.email:
          formField = _widget as EmailFormField;
          break;
        case LisoFieldType.phone:
          formField = _widget as PhoneFormField;
          break;
        case LisoFieldType.pin:
          formField = _widget as PINFormField;
          break;
        case LisoFieldType.gender:
          formField = _widget as GenderFormField;
          break;
        case LisoFieldType.country:
          formField = _widget as CountryFormField;
          break;
        case LisoFieldType.address:
          formField = _widget as AddressFormField;
          break;
        default:
      }

      if (formField != null) {
        _field.data['value'] = formField.value;
      }

      _newFields.add(_field);
    }

    return _newFields;
  }
}
