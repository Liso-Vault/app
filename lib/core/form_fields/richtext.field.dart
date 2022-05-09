import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:console_mixin/console_mixin.dart';

// ignore: must_be_immutable
class RichTextFormField extends StatelessWidget with ConsoleMixin {
  final HiveLisoField field;
  RichTextFormField(this.field, {Key? key}) : super(key: key);

  QuillController? _fieldController;

  String get value {
    try {
      return jsonEncode(_fieldController!.document.toDelta().toJson());
    } catch (e) {
      console.error('message');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (field.data.value != null && field.data.value!.isEmpty) {
      _fieldController = QuillController.basic();
    } else {
      dynamic json;

      try {
        json = jsonDecode(field.data.value!);

        _fieldController = QuillController(
          document: Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        console.error('json error: $e');
        _fieldController = QuillController.basic();
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QuillToolbar.basic(
          controller: _fieldController!,
          multiRowsDisplay: false,
        ),
        const Divider(),
        SizedBox(
          height: 300,
          child: QuillEditor.basic(
            controller: _fieldController!,
            readOnly: false, // true for view only mode
          ),
        ),
        const Divider(),
      ],
    );
  }
}
