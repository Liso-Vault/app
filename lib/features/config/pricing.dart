import 'package:app_core/globals.dart';
import 'package:app_core/pages/upgrade/pricing.model.dart';
import 'package:get/get.dart';

class AppPricing {
  static final features = [
    'premium_desc_1',
    'premium_desc_2',
    'premium_desc_3',
    'premium_desc_4',
    'premium_desc_5',
    'premium_desc_6',
    'premium_desc_7',
    'premium_desc_8',
    'premium_desc_9',
    'premium_desc_10',
    'premium_desc_11',
    'premium_desc_12',
    // 'premium_no_ads',
    // 'premium_gpt',
    // 'premium_docs_editor',
    // 'premium_languages',
    // 'premium_templates',
    // 'premium_continue_writer',
    // 'premium_commands',
    // 'premium_tts',
    // 'premium_support',
    deviceAccess,
    'money_back_guarantee',
    if (!isApple || !isAppStore) ...[
      'cancel_anytime',
    ],
    'join_over_users',
  ];

  static final upcomingFeatures = [
    // 'premium_seo',
    // 'premium_plagiarism',
    // 'premium_art',
    // 'premium_stt',
    // 'premium_teams',
  ];

  // static final starter = {
  //   'id': 'starter',
  //   'primary_feature': 'premium_starter_limit',
  //   'features': features,
  //   'upcoming_features': upcomingFeatures,
  // };

  // static final plus = {
  //   'id': 'plus',
  //   'primary_feature': 'premium_plus_limit',
  //   'features': features,
  //   'upcoming_features': upcomingFeatures,
  // };

  static final pro = {
    'id': 'pro',
    'primary_feature': 'premium_pro_limit',
    'features': features,
    'upcoming_features': upcomingFeatures,
  };

  static final max = {
    'id': 'max',
    'primary_feature': 'premium_max_limit',
    'features': features,
    'upcoming_features': upcomingFeatures,
  };

  static final data = {
    // MONTHLY
    // 'starter.sub.monthly': Pricing.fromJson(starter),
    // 'plus.sub.monthly': Pricing.fromJson(plus),
    'pro.sub.monthly': Pricing.fromJson(pro),
    // 'max.sub.monthly': Pricing.fromJson(max),
    // ANNUAL
    // 'starter.sub.annual': Pricing.fromJson(starter),
    // 'plus.sub.annual': Pricing.fromJson(plus),
    'pro.sub.annual': Pricing.fromJson(pro),
    // 'max.sub.annual': Pricing.fromJson(max),
  };

  static String get deviceAccess {
    String text = 'Other devices';

    if (isMac) {
      text = 'iOS, Web, and ${'other_platform_access'.tr}';
    } else if (GetPlatform.isIOS) {
      text = 'macOS, Web, and ${'other_platform_access'.tr}';
    } else if (GetPlatform.isAndroid) {
      text = 'iOS, macOS, Windows, \nand Web ${'app_access'.tr}';
    } else if (isWindows) {
      text = 'iOS, macOS, Android, \nand Web ${'app_access'.tr}';
    } else if (isLinux) {
      text = 'iOS, macOS, Windows, Android, \nand Web ${'app_access'.tr}';
    } else if (isWeb) {
      text = 'iOS, macOS, Windows, \nand Android ${'app_access'.tr}';
    }

    return text;
  }
}
