import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/selector.sheet.dart';
import 'package:liso/features/json_viewer/json_viewer.screen.dart';

class MainScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static MainScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <HiveSeed>[].obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    initAppLifeCycleEvents();
    load();
    super.onInit();
  }

  // FUNCTIONS
  void load() async {
    change(null, status: RxStatus.loading());

    // show welcome screen if not authenticated
    if (!(await LisoManager.authenticated())) {
      await Get.toNamed(Routes.welcome);
      await Get.toNamed(Routes.createPassword);
    } else {
      if (encryptionKey == null) {
        await Get.toNamed(Routes.unlock);
      }
    }

    data.value = HiveManager.seeds!.values.toList();

    if (data.isEmpty) {
      change(null, status: RxStatus.empty());
    } else {
      change(null, status: RxStatus.success());
    }
  }

  void add() => Get.toNamed(Routes.seed, parameters: {'mode': 'add'});

  void onLongPress(HiveSeed object) {
    SelectorSheet(
      items: [
        SelectorItem(
          title: 'Copy Address',
          subTitle: object.address,
          leading: const Icon(LineIcons.copy),
          onSelected: () => Utils.copyToClipboard(object.address),
        ),
        SelectorItem(
          title: 'Copy Mnemonic Phrase',
          subTitle: 'Copy at your own risk',
          leading: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
          onSelected: () => Utils.copyToClipboard(object.mnemonic),
        ),
        SelectorItem(
          title: 'Details',
          subTitle: 'In JSON format',
          leading: const Icon(LineIcons.laptopCode),
          onSelected: () {
            Get.to(() => JSONViewerScreen(data: object.toJson()));
          },
        ),
      ],
    ).show();
  }

  void initAppLifeCycleEvents() {
    // auto-lock after app is inactive
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        if (await LisoManager.authenticated() && encryptionKey == null) {
          Get.toNamed(Routes.unlock);
        }
      } else if (msg == AppLifecycleState.inactive.toString()) {
        // lock after 1 minute of inactivity
        Future.delayed(1.minutes).then((value) => encryptionKey = null);
      }

      return Future.value(msg);
    });
  }
}
