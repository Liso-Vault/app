import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';

import 'model/profile.model.dart';
import 'supabase_auth.service.dart';

class SupabaseDBService extends GetxService with ConsoleMixin {
  static SupabaseDBService get to => Get.find();

  // VARIABLES
  final auth = Get.find<SupabaseAuthService>();

  // GETTERS

  // FUNCTIONS

  Future<Either<dynamic, SupabaseProfile>> updateLicenseKey(String key) async {
    if (!auth.authenticated) {
      console.warning('not authenticated');
      return const Left('not authenticated');
    }

    // UPDATE PROFILE
    try {
      final response = await auth.client!.from('profiles').upsert(
        {
          'id': auth.user!.id,
          'gumroad_license_key': key,
          'updated_at': 'now()',
        },
      ).select();

      // console.info('Upsert success! $response');

      if (response.isEmpty) {
        return const Left('Upsert Profile Error: empty data response');
      }

      final profile = SupabaseProfile.fromJson(response.first);
      return Right(profile);
    } catch (e) {
      return Left('Upsert Profile Error: $e');
    }
  }
}
