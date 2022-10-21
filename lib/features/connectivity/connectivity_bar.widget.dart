import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/persistence/persistence_builder.widget.dart';
import 'package:liso/features/connectivity/connectivity.service.dart';

class ConnectivityBar extends StatelessWidget {
  const ConnectivityBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: GetPlatform.isMobile ? AppSettings.openWIFISettings : null,
      child: Container(
        height: 20,
        color: Colors.red.withOpacity(0.3),
        child: const Center(
          child: Text(
            'No Internet Connection',
            style: TextStyle(fontSize: 11),
          ),
        ),
      ),
    );

    return PersistenceBuilder(
      builder: (p, _) {
        return Obx(
          () => !ConnectivityService.to.connected() && p.sync.val
              ? content
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
