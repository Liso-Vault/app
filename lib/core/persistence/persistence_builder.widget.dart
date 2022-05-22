import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import 'persistence.dart';

class PersistenceBuilder extends StatefulWidget {
  final Widget Function(Persistence, BuildContext) builder;
  const PersistenceBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  State<PersistenceBuilder> createState() => _PersistenceBuilderState();
}

class _PersistenceBuilderState extends State<PersistenceBuilder> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<Persistence>(
      init: Persistence.to,
      builder: (_) => widget.builder(_, context),
    );
  }
}
