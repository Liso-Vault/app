import 'package:bip39/bip39.dart' as bip39;
import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/app/routes.dart';

class MnemonicScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MnemonicScreenController());
  }
}

class MnemonicScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES
  final mnemonic = ''.obs;
  final chkBackedUpSeed = false.obs;
  final chkWrittenSeed = false.obs;

  // GETTERS
  bool get canProceed => chkBackedUpSeed() && chkWrittenSeed();

  // INIT
  @override
  void onInit() {
    mnemonic.value = bip39.generateMnemonic(strength: 256);
    super.onInit();
  }

  // FUNCTIONS

  void continuePressed() async {
    final seedHex = bip39.mnemonicToSeedHex(mnemonic.value);
    Get.toNamed(Routes.createPassword, parameters: {'seedHex': seedHex});
  }
}
