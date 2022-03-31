import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/selector.sheet.dart';

class MainScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static MainScreenController get to => Get.find();

  // VARIABLES
  Timer? timer;

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    _initAppLifeCycleEvents();
    _setDisplayMode();
    _load();

    super.onInit();
  }

  @override
  void onReady() {
    HiveManager.items?.watch().listen((event) {
      // console.warning(
      //   'Event: key: ${event.key}, value: ${event.value}, deleted: ${event.deleted}',
      // );

      // if (event.deleted) {
      //   data.removeWhere((e) => e.key == event.key);
      // }

      _load();
    });

    super.onReady();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  // FUNCTIONS
  void reload() => _load();

  void _load() async {
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

    var items = HiveManager.items!.values.toList();

    // FILTER BY CATEGORY
    if (filterCategory != null) {
      items = items.where((e) => e.category == filterCategory!.name).toList();
    }

    // FILTER FAVORITES
    if (filterFavorites) {
      items = items.where((e) => e.favorite).toList();
    }

    // sort from latest to oldest
    items.sort(
      (a, b) => b.metadata.updatedTime.compareTo(a.metadata.updatedTime),
    );

    data.value = items;

    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());
  }

  // void add() => Get.toNamed(Routes.seed, parameters: {'mode': 'add'});

  void add() {
    SelectorSheet(
      items: LisoItemCategory.values
          .map((e) => e.name)
          .map((e) => SelectorItem(
                title: e.tr,
                // TODO: use a constant variable for path
                leading: Image.asset(
                  'assets/images/categories/$e.png',
                  height: 20,
                ),
                onSelected: () => Get.toNamed(
                  Routes.item,
                  parameters: {'mode': 'add', 'category': e},
                ),
              ))
          .toList(),
    ).show();
  }

  void onLongPress(HiveLisoItem object) {
    // SelectorSheet(
    //   items: [
    //     SelectorItem(
    //       title: 'Copy Address',
    //       subTitle: object.address,
    //       leading: const Icon(LineIcons.copy),
    //       onSelected: () => Utils.copyToClipboard(object.address),
    //     ),
    //     SelectorItem(
    //       title: 'Copy Mnemonic Phrase',
    //       subTitle: 'Copy at your own risk',
    //       leading: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
    //       onSelected: () => Utils.copyToClipboard(object.mnemonic),
    //     ),
    //     SelectorItem(
    //       title: 'Details',
    //       subTitle: 'In JSON format',
    //       leading: const Icon(LineIcons.laptopCode),
    //       onSelected: () {
    //         Get.to(() => JSONViewerScreen(data: object.toJson()));
    //       },
    //     ),
    //   ],
    // ).show();
  }

  void _initAppLifeCycleEvents() {
    // auto-lock after app is inactive
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      console.warning(msg!);

      if (msg == AppLifecycleState.resumed.toString()) {
        timer?.cancel();

        if (await LisoManager.authenticated() && encryptionKey == null) {
          Get.toNamed(Routes.unlock);
        }
      } else if (msg == AppLifecycleState.inactive.toString()) {
        // lock after <duration> of inactivity
        if (timeLockEnabled) {
          final timeLock =
              PersistenceController.to.timeLockDuration.val.seconds;
          timer = Timer.periodic(timeLock, (timer) {
            encryptionKey = null;
            timer.cancel();
          });
        }
      }

      return Future.value(msg);
    });
  }

  // support higher refresh rate
  void _setDisplayMode() async {
    if (!GetPlatform.isAndroid) return;

    try {
      final mode = await FlutterDisplayMode.active;
      console.warning('active mode: $mode');

      final modes = await FlutterDisplayMode.supported;

      for (DisplayMode e in modes) {
        console.info('display modes: $e');
      }

      await FlutterDisplayMode.setPreferredMode(modes.last);
      console.info('set mode: ${modes.last}');
    } on PlatformException catch (e) {
      console.error('display mode error: $e');
    }
  }
}
