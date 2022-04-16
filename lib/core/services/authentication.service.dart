import 'dart:io';

import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';

import '../liso/liso.manager.dart';

class AuthenticationService extends GetxService with ConsoleMixin {
  static AuthenticationService get to => Get.find();

  bool get isAuthenticated {
    return File(LisoManager.walletFilePath).existsSync();
  }
}
