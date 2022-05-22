import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/utils/secrets.dart';

import '../liso/liso_paths.dart';
import '../utils/globals.dart';

class Persistence extends GetxController with ConsoleMixin {
  // STATIC
  static Persistence get to => Get.find();
  static late Box box;

  // VARIABLES

  // PROPERTIES
  final test = 'default'.val('test');

  // FUNCTIONS
  static Future<void> init() async {
    box = await Hive.openBox(
      kHivePersistence,
      encryptionCipher: HiveAesCipher(base64Decode(kHivePersistenceCipherKey)),
      path: LisoPaths.hivePath,
    );
  }
}

class MutableValue<T> {
  final String key;
  MutableValue(this.key);

  T get val => Persistence.box.get(key);

  set val(T value) {
    Persistence.box.put(key, value);
    Persistence.to.update();
  }
}

extension Data<T> on T {
  MutableValue<T> val(String key) => MutableValue(key);
}
