import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

// ignore: must_be_immutable
class TextFieldForm extends StatelessWidget {
  final HiveLisoField field;
  TextFieldForm(this.field, {Key? key}) : super(key: key);

  TextEditingController? _fieldController;

  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data['value']);

    return TextFormField(
      controller: _fieldController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: field.data['label'],
        hintText: field.data['hint'],
      ),
    );
  }
}
