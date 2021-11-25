import 'package:get/get.dart';
import 'package:liso/core/app.manager.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
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
  // TODO: Storage Keys: seeds = list of encrypted seeds
  // TODO: Storage Keys: metadata = createdTime, updatedTime, app (name,version), device
  // TODO: Biometric

  void load() async {
    // AppManager.reset();

    change(null, status: RxStatus.loading());

    // show welcome screen if not authenticated
    if (!(await AppManager.authenticated())) {
      await Get.toNamed(Routes.welcome);
      await Get.toNamed(Routes.createPassword);
    } else {
      if (encryptionKey == null) {
        await Get.toNamed(Routes.unlock);
      }
    }

    await AppManager.init();

    data.value = HiveManager.seeds!.values.toList();

    if (data.isEmpty) {
      change(null, status: RxStatus.empty());
    } else {
      change(null, status: RxStatus.success());
    }
  }

  void add() => Get.toNamed(Routes.seed, parameters: {'mode': 'add'});

  // TODO: remove crypter and this function
  // void aes() async {
  //   const mnemonic =
  //       'measure raccoon fox tide infant broken process salute umbrella dinner hybrid pretty';
  //   final seedHex = bip39.mnemonicToSeedHex(mnemonic);
  //   // use first 32 bytes of mnemonic seed hex as secret key
  //   final secreyKeyString = seedHex.substring(0, 32);

  //   // Secure Storage
  //   const storage = FlutterSecureStorage();
  //   const storageKey = 'seeds';

  //   final crypter = LisoCrypter();
  //   await crypter.initSecretyKey(utf8.encode(secreyKeyString));

  //   console.info('\n\nLiso Crypter');
  //   final encrypted = await crypter.encrypt('testing'.codeUnits);
  //   console.info('Encrypted: ${String.fromCharCodes(encrypted.cipherText)}');

  //   console.warning('json: ${encrypted.toJsonEncoded()}');

  //   await storage.write(
  //     key: storageKey,
  //     value: encrypted.toJsonEncoded(),
  //   );

  //   final value = await storage.read(key: storageKey);
  //   console.info('storage ($storageKey) value: $value');

  //   final secretBox = SecretBoxExtension.fromJson(jsonDecode(value!));
  //   final decrypted = await crypter.decrypt(secretBox);

  //   console.info('Decrypted: ${String.fromCharCodes(decrypted)}');
  // }
}
