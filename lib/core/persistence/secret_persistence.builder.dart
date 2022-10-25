import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'persistence.secret.dart';

class SecretPersistenceBuilder extends StatefulWidget {
  final Widget Function(SecretPersistence, BuildContext) builder;
  const SecretPersistenceBuilder({Key? key, required this.builder})
      : super(key: key);

  @override
  State<SecretPersistenceBuilder> createState() =>
      _SecretPersistenceBuilderState();
}

class _SecretPersistenceBuilderState extends State<SecretPersistenceBuilder> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SecretPersistence>(
      init: SecretPersistence.to,
      builder: (_) => widget.builder(_, context),
    );
  }
}
