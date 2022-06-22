import 'package:flutter/material.dart';

class SpacerFormField extends StatelessWidget {
  const SpacerFormField({Key? key}) : super(key: key);

  // GETTERS
  String get value => '';

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 10);
  }
}
