import 'package:console_mixin/console_mixin.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';

import '../../core/firebase/analytics.service.dart';
import '../../core/firebase/config/config.service.dart';
import '../../core/firebase/crashlytics.service.dart';
import '../../core/persistence/persistence.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/utils/globals.dart';
import '../pro/pro.controller.dart';
import '../wallet/wallet.service.dart';

class SupabaseAuthService extends GetxService with ConsoleMixin {
  static SupabaseAuthService get to => Get.find();

  // VARIABLES
  final persistence = Get.find<Persistence>();
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

    initAuthState();
    var sessionString = persistence.supabaseSession.val;
    if (sessionString.isEmpty) return console.warning('no supabase session');

    try {
      final session = await client!.auth.recoverSession(sessionString);
      console.info('recovered session! user id: ${session.user?.id}');
    } on AuthException catch (e) {
      console.error('recover session error: $e');
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      console.error('recover session exception: $e');
    }
  }

  void initAuthState() {
    client!.auth.onAuthStateChange.listen((data) {
      console.info(
        'onAuthStateChange! ${data.event}: user id: ${data.session?.user.id}',
      );

      persistence.supabaseSession.val =
          data.session?.persistSessionString ?? '';

      if (data.event == AuthChangeEvent.signedIn) {
        EasyDebounce.debounce('auth-sign-in', 5.seconds, () async {
          if (!authenticated) return;

          if (!isWindowsLinux) {
            await CrashlyticsService.to.instance.setUserIdentifier(user!.id);
            await AnalyticsService.to.instance.setUserId(id: user!.id);
          }

          ProController.to.login(user!);
          AnalyticsService.to.logSignIn();
        });
      } else if (data.event == AuthChangeEvent.signedOut) {
        EasyDebounce.debounce('auth-sign-out', 1.seconds, () {
          ProController.to.logout();
          AnalyticsService.to.logSignOut();
        });
      } else if (data.event == AuthChangeEvent.tokenRefreshed) {
        //
      } else if (data.event == AuthChangeEvent.userUpdated) {
        //
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await client!.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      // invalid credentials
      if (e.statusCode == '400') {
        return console.error('signIn error: $e');
      } else {
        return console.error('signIn error: $e');
      }
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      return console.error('signIn exception: $e');
    }
  }

  Future<void> authenticate() async {
    if (authenticated) return console.info('already authenticated');
    final address = SecretPersistence.to.walletAddress.val;
    final email = '$address@liso.dev';
    final password = await WalletService.to.sign(kAuthSignatureMessage);

    try {
      await client!.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      // already registered
      if (e.statusCode == '400') {
        await signIn(email, password);
      } else {
        return console.error('signUp error: $e');
      }
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      return console.error('signIn exception: $e');
    }

    console.wtf('authentication successful');
  }

  Future<void> signOut() async {
    client!.auth.signOut();
  }
}
