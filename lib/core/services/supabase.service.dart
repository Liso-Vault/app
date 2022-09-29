import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';

import '../firebase/config/config.service.dart';

class SupabaseService extends GetxService with ConsoleMixin {
  static SupabaseService get to => Get.find();

  // VARIABLES
  final config = Get.find<ConfigService>();

  SupabaseClient? client;

  // GETTERS
  bool get authenticated => user != null;
  User? get user => client?.auth.currentUser;

  @override
  void onReady() {
    init();
    super.onReady();
  }

  // FUNCTIONS
  Future<void> init() async {
    client = SupabaseClient(
      config.secrets.supabase.url,
      config.secrets.supabase.key,
    );
  }
}
