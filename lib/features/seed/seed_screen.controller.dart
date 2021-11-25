import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/metadata.hive.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/general/selector.sheet.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/passphrase_card/passphrase.card.dart';
import 'package:liso/features/passphrase_card/passphrase_card.controller.dart';

const originItems = [
  'Metamask',
  'TrustWallet',
  'Exodus',
  'MyEtherWallet',
  'BitGo',
  'Math Wallet'
];

const ledgerItems = [
  'Blockchain',
  'Hashgraph',
  'Directed Acyclic Graph',
  'Holochain',
  'Tempo',
];

class SeedScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SeedScreenController());
  }
}

class SeedScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  // VARIABLES
  HiveSeed? object;

  final formKey = GlobalKey<FormState>();
  final mode = Get.parameters['mode'] as String;

  PassphraseCard? passphraseCard;
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  final originDropdownItems = originItems
      .map(
        (e) => DropdownMenuItem(child: Text(e), value: e),
      )
      .toList();

  final ledgerDropdownItems = ledgerItems
      .map(
        (e) => DropdownMenuItem(child: Text(e), value: e),
      )
      .toList();

  // PROPERTIES
  final selectedOrigin = originItems.first.obs;
  final selectedLedger = ledgerItems.first.obs;

  // GETTERS

  // INIT

  @override
  void onInit() {
    if (mode == 'add') {
      passphraseCard = const PassphraseCard(mode: PassphraseMode.none);
    } else if (mode == 'update') {
      final index = int.parse(Get.parameters['index'].toString());
      object = HiveManager.seeds?.getAt(index);

      passphraseCard = PassphraseCard(
        mode: PassphraseMode.none,
        phrase: object!.seed,
      );

      addressController.text = object!.address;
      descriptionController.text = object!.description;
      selectedOrigin.value = object!.origin;
      selectedLedger.value = object!.ledger;
    }

    super.onInit();
  }

  // FUNCTIONS

  void showSeedOptions() {
    SelectorSheet(
      title: 'Seed Options',
      items: [
        SelectorItem(
          title: 'Generate 12 words',
          leading: const Icon(Icons.refresh),
          onSelected: passphraseCard!.controller.generate12Seed,
        ),
        SelectorItem(
          title: 'Generate 24 words',
          leading: const Icon(Icons.refresh),
          onSelected: passphraseCard!.controller.generate24Seed,
        ),
      ],
    ).show();
  }

  void add() async {
    if (!formKey.currentState!.validate()) return;

    final newSeed = HiveSeed(
      seed: passphraseCard!.obtainSeed()!,
      address: addressController.text,
      description: descriptionController.text,
      ledger: selectedLedger.value,
      origin: selectedOrigin.value,
      metadata: await HiveMetadata.get(),
    );

    await HiveManager.seeds!.add(newSeed);
    MainScreenController.to.load();
    Get.back();

    console.info('success');
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;
    if (object == null) return;

    object!.seed = passphraseCard!.obtainSeed()!;
    object!.address = addressController.text;
    object!.description = descriptionController.text;
    object!.origin = selectedOrigin.value;
    object!.ledger = selectedLedger.value;
    object!.metadata = await object!.metadata.getUpdated();
    await object?.save();

    MainScreenController.to.load();
    Get.back();

    console.info('success');
  }

  void delete() async {
    await object?.delete();
    MainScreenController.to.load();
    Get.back();

    console.info('success');
  }

  void changedOriginItem(String? item) {
    selectedOrigin.value = item!;
  }

  void changedLedgerItem(String? item) {
    selectedLedger.value = item!;
  }
}
