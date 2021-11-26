import 'package:flutter/material.dart';
import 'package:get/utils.dart';

class Styles {
  static final roundedBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  static final outlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
  );

  static final elevatedButtonStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: GetPlatform.isDesktop ? 15 : 10),
    shape: roundedBorder,
  );

  static final elevatedButtonStyleNegative = ElevatedButton.styleFrom(
    primary: Colors.red,
    padding: EdgeInsets.symmetric(vertical: GetPlatform.isDesktop ? 15 : 10),
    shape: roundedBorder,
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
  );

  static const containerConstraints = BoxConstraints(maxWidth: 500);
}
