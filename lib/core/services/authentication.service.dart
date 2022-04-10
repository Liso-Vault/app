import 'dart:io';

import 'package:get/get.dart';

import '../liso/liso_paths.dart';
import '../utils/globals.dart';

class AuthenticationService extends GetxService {
  static AuthenticationService get to => Get.find();

  bool get isAuthenticated {
    final walletPath = '${LisoPaths.main!.path}/$kLocalMasterWalletFileName';
    return File(walletPath).existsSync();
  }
}
