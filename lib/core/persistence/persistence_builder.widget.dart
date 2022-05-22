import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import 'persistence.dart';

class PersistenceBuilder extends StatelessWidget {
  final Widget Function(Persistence) builder;
  const PersistenceBuilder(this.builder, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Persistence>(
      init: Persistence.to,
      builder: builder,
    );
  }
}
