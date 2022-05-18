import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ContextMenuItem extends Equatable {
  final String title;
  final String? value;
  final Widget? leading;
  final Widget? trailing;
  final Function? onSelected;

  const ContextMenuItem({
    required this.title,
    this.value,
    this.leading,
    this.trailing,
    this.onSelected,
  });

  @override
  List<Object?> get props => [
        title,
        value,
        leading,
        trailing,
        onSelected,
      ];

  @override
  int get hashCode => title.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! ContextMenuItem) return false;
    if (title != other.title) return false;
    return true;
  }
}
