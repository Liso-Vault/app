import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:liso/core/hive/models/field.hive.dart';

// ignore: must_be_immutable
class RichTextFormField extends StatelessWidget with ConsoleMixin {
  final HiveLisoField field;
  final bool readOnly;

  RichTextFormField(
    this.field, {
    super.key,
    this.readOnly = false,
  });

  QuillController? _fieldController;

  String get value {
    try {
      return jsonEncode(_fieldController!.document.toDelta().toJson());
    } catch (e) {
      // console.error('value error: $e');
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
        // console.error('json error: $e');
        _fieldController = QuillController.basic();
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!readOnly) ...[
          // QuillToolbar.basic(
          //   controller: _fieldController!,
          //   multiRowsDisplay: false,
          // ),
          // const QuillToolbar(
          //   configurations: QuillToolbarConfigurations(
          //     multiRowsDisplay: false,
          //   ),
          // ),
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              controller: _fieldController!,
              // multiRowsDisplay: false,
              // showFontFamily: false,
              // showFontSize: false,
              // showSearchButton: false,
              // showUnderLineButton: false,
              // showColorButton: false,
              // showBackgroundColorButton: false,
              // showStrikeThrough: false,
              // showListCheck: false,
              sharedConfigurations: const QuillSharedConfigurations(),
            ),
          ),
          const Divider(),
        ],
        SizedBox(
          height: 300,
          // child: QuillEditor.basic(
          //   configurations: QuillEditorConfigurations(readOnly: readOnly),
          // ),
          child: QuillEditor(
            scrollController: ScrollController(),
            focusNode: FocusNode(),
            configurations: QuillEditorConfigurations(
              controller: _fieldController!,
              // readOnly: false,
              // scrollable: true,
              // expands: false,
              // autoFocus: false,
              // placeholder: 'quill_placeholder'.tr,
              // enableInteractiveSelection: true,
              // padding: EdgeInsets.zero,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
