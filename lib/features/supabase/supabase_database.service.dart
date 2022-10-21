import 'dart:convert';

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
    final upsertProfileRes = await auth.client!.from('profiles').upsert(
      {
        'id': auth.user!.id,
        'gumroad_license_key': key,
        'updated_at': 'now()',
      },
    );

    if (upsertProfileRes.hasError) {
      return Left(
        'Error: ${upsertProfileRes.error?.code} : ${upsertProfileRes.error?.message}',
      );
    }

    console.wtf('upsert profiles! ${jsonEncode(upsertProfileRes.toJson())}');

    if (upsertProfileRes.data.isEmpty) {
      return const Left('Upsert Profile Error: empty data response');
    }

    final profile = SupabaseProfile.fromJson(upsertProfileRes.data.first);
    return Right(profile);
  }
}
