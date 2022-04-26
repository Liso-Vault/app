import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

class SectionFormField extends StatelessWidget {
  final HiveLisoField field;
  const SectionFormField(this.field, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        field.data.value!.toUpperCase(),
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }
}
