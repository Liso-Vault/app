import 'package:get/get.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';

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
    load();
    super.onInit();
  }

  // FUNCTIONS

  // TODO: Export Master Seed as Wallet JSON
  // TODO: Import Wallet JSON as Master Seed
  // TODO: Biometric

  void load() async {
    // await LisoManager.reset();

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
}
