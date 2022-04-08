import 'package:flutter/material.dart';

class ContextMenuItem {
  final String title;
  final Widget? leading;
  final Function? function;

  const ContextMenuItem({
    required this.title,
    this.leading,
    this.function,
  });
}
