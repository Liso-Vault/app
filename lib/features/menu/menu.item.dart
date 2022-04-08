import 'package:flutter/material.dart';

class ContextMenuItem {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final Function? function;

  const ContextMenuItem({
    required this.title,
    this.leading,
    this.trailing,
    this.function,
  });
}
