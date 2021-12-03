import 'package:flutter/material.dart';

class Styles {
  static final roundedBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  static final outlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
  );

  static final elevatedButtonStyle = ElevatedButton.styleFrom(
    shape: roundedBorder,
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

  static final elevatedButtonStyleNegative = ElevatedButton.styleFrom(
    primary: Colors.red,
    shape: roundedBorder,
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

  static final textButtonStyleNegative = OutlinedButton.styleFrom(
    primary: Colors.red,
    shape: roundedBorder,
  );

  static final inputDecoration = InputDecoration(
    enabledBorder: outlineBorder,
    errorBorder: outlineBorder,
    focusedBorder: outlineBorder,
    focusedErrorBorder: outlineBorder,
    isDense: true,
  );

  static const containerConstraints = BoxConstraints(maxWidth: 500);
}
