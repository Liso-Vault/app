import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetRefresher extends StatelessWidget {
  final Widget child;
  final WidgetRefresherController controller;

  const WidgetRefresher({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: controller.visible.value,
        child: child,
      ),
    );
  }
}

class WidgetRefresherController extends GetxController {
  final visible = true.obs;

  void reload() async {
    visible.toggle();
    await Future.delayed(50.milliseconds);
    visible.toggle();
  }
}
