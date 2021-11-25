import 'package:get/get.dart';
import 'package:liso/features/passphrase_card/passphrase_card.controller.dart';

import 'main_screen.controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainScreenController());

    // GET WIDGETS
    Get.create(() => PassphraseCardController());
  }
}
