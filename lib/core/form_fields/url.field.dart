import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:liso/core/hive/models/field.hive.dart';

// ignore: must_be_immutable
class URLFormField extends StatelessWidget {
  final HiveLisoField field;
  URLFormField(this.field, {Key? key}) : super(key: key);

  TextEditingController? _fieldController;

  String get value => _fieldController!.text;

  @override
  Widget build(BuildContext context) {
    _fieldController = TextEditingController(text: field.data.value);

    return TextFormField(
      controller: _fieldController,
      readOnly: field.readOnly,
      keyboardType: TextInputType.url,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (data) =>
          data!.isEmpty || GetUtils.isURL(data) ? null : 'Invalid URL',
      decoration: InputDecoration(
        labelText: field.data.label,
        hintText: field.data.hint,
      ),
    );
  }
}
