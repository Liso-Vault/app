import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/alchemy.service.dart';

class AssetsScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static AssetsScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onReady() {
    load();
    super.onReady();
  }

  void load() async {
    change(null, status: RxStatus.loading());
    await AlchemyService.to.load();
    change(null, status: RxStatus.success());
  }
}
