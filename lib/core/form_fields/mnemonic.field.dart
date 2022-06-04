import 'package:flutter/material.dart';
import 'package:liso/core/hive/models/field.hive.dart';

import '../../features/general/passphrase.card.dart';

// ignore: must_be_immutable
class MnemonicFormField extends StatelessWidget {
  final HiveLisoField field;
  MnemonicFormField(this.field, {Key? key}) : super(key: key);

  // VARIABLES
  final _fieldController = TextEditingController();

  // GETTERS
  String get value => _fieldController.text;

  @override
  Widget build(BuildContext context) {
    return PassphraseCard(
      fieldController: _fieldController,
      initialValue: field.data.value ?? '',
      required: false,
    );
  }
}
