import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/core/utils/console.dart';

// ignore: must_be_immutable
class TextAreaFormField extends StatelessWidget with ConsoleMixin {
  final HiveLisoField field;
  TextAreaFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? _fieldController;

  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data.value);

    return TextFormField(
      controller: _fieldController,
      minLines: 3,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: field.data.label,
        hintText: field.data.hint,
      ),
    );
  }
}
