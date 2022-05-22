import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/connectivity/connectivity.service.dart';

class ConnectivityBar extends StatelessWidget {
  const ConnectivityBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: GetPlatform.isMobile ? AppSettings.openWIFISettings : null,
      child: Container(
        height: 20,
        color: Colors.red,
        child: const Center(
          child: Text(
            'No Internet Connection',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
    );

    return Obx(
      () => !ConnectivityService.to.connected() && Persistence.to.sync.val
          ? content
          : const SizedBox.shrink(),
    );
  }
}
