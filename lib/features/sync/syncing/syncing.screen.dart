import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/sync/syncing/syncing_screen.controller.dart';

import '../../general/centered_placeholder.widget.dart';

class SyncingScreen extends GetView<SyncingScreenController> {
  const SyncingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = controller.obx(
      (_) => const Material(child: SizedBox.shrink()),
      onLoading: Material(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 30),
              Text('Syncing...'),
            ],
          ),
        ),
      ),
      onError: (message) => Material(
        child: CenteredPlaceholder(
          iconData: LineIcons.exclamationTriangle,
          message: message!,
          child: TextButton.icon(
            label: const Text('Try again'),
            icon: const Icon(LineIcons.syncIcon),
            onPressed: controller.sync,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: controller.obx(
          (state) => const SizedBox.shrink(),
          onLoading: const SizedBox.shrink(),
          onError: (message) => IconButton(
            onPressed: controller.cancel,
            icon: const Icon(LineIcons.times),
          ),
        ),
      ),
      body: content,
    );
  }
}
