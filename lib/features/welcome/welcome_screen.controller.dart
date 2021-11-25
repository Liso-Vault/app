import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WelcomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WelcomeScreenController());
  }
}

class WelcomeScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES
  final packageInfo = Rxn<PackageInfo>();

  // GETTERS
  String get appVersion =>
      '${packageInfo()?.version}+${packageInfo()?.buildNumber}';

  // INIT
  @override
  void onInit() async {
    packageInfo.value = await PackageInfo.fromPlatform();
    super.onInit();
  }

  // FUNCTIONS
}
