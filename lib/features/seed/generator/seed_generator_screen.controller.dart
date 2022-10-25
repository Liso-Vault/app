import 'package:app_core/utils/utils.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

import '../../../core/utils/globals.dart';
import '../../app/routes.dart';

class SeedGeneratorScreenController extends GetxController with ConsoleMixin {
  static SeedGeneratorScreenController get to => Get.find();

  // VARIABLES
  final isFromDrawer = Get.parameters['from'] == 'drawer';

  // PROPERTIES

  // PROPERTIES
  final seed = ''.obs;
  final strength = 256.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    generate();
    super.onInit();
  }

  // FUNCTIONS
  void generate() {
    seed.value = bip39.generateMnemonic(strength: strength.value);
  }

  void save() {
    Utils.adaptiveRouteOpen(
      name: AppRoutes.item,
      parameters: {
        'mode': 'generated',
        'category': LisoItemCategory.cryptoWallet.name,
        'value': seed.value,
      },
    );
  }
}
