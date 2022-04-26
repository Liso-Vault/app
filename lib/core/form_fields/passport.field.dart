import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:liso/core/hive/models/field.hive.dart';

// ignore: must_be_immutable
class PassportFormField extends StatelessWidget {
  final HiveLisoField field;
  PassportFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? _fieldController;
  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data.value);

    return TextFormField(
      controller: _fieldController,
      validator: (data) => data!.isEmpty || GetUtils.isPassport(data)
          ? null
          : 'Invalid Passport',
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: field.data.label,
        hintText: field.data.hint,
      ),
    );
  }
}
