import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:path/path.dart';

import '../../hive/models/field.hive.dart';
import 'models/config_app.model.dart';
import 'models/config_global.model.dart';
import 'models/config_s3.model.dart';

class ConfigService extends GetxService with ConsoleMixin {
  static ConfigService get to => Get.find();

  // VARIABLES
  var general = const ConfigGeneral();
  var app = const ConfigApp();
  var s3 = const ConfigS3();

  List<HiveLisoFieldChoices> choicesCountry = [];
  List<HiveLisoField> templateAPICredential = [];
  List<HiveLisoField> templateBankAccount = [];
  List<HiveLisoField> templateCashCard = [];
  List<HiveLisoField> templateCryptoWallet = [];
  List<HiveLisoField> templateDatabase = [];
  List<HiveLisoField> templateDriversLicense = [];
  List<HiveLisoField> templateEmailAccount = [];
  List<HiveLisoField> templateEncryption = [];
  List<HiveLisoField> templateIdentity = [];
  List<HiveLisoField> templateLogin = [];
  List<HiveLisoField> templateMedicalRecord = [];
  List<HiveLisoField> templateMembership = [];
  List<HiveLisoField> templateNote = [];
  List<HiveLisoField> templateOutdoorLicense = [];
  List<HiveLisoField> templatePassport = [];
  List<HiveLisoField> templatePassword = [];
  List<HiveLisoField> templateRewardsProgram = [];
  List<HiveLisoField> templateServer = [];
  List<HiveLisoField> templateSocialSecurity = [];
  List<HiveLisoField> templateSoftwareLicense = [];
  List<HiveLisoField> templateWirelessRouter = [];

  final parameters = [
    'general_config',
    'app_config',
    's3_config',
    'choices_country',
    'template_api_credential',
    'template_bank_account',
    'template_cash_card',
    'template_crypto_wallet',
    'template_database',
    'template_drivers_license',
    'template_email_account',
    'template_encryption',
    'template_identity',
    'template_login',
    'template_medical_record',
    'template_membership',
    'template_note',
    'template_outdoor_license',
    'template_passport',
    'template_password',
    'template_rewards_program',
    'template_server',
    'template_social_security',
    'template_software_license',
    'template_wireless_router',
  ];

  // GETTERS
  FirebaseRemoteConfig get instance => FirebaseRemoteConfig.instance;
  String get appName => general.app.name;
  String get devName => general.developer.name;

  // INIT
  @override
  void onInit() {
    _init();
    console.info('onInit');
    super.onInit();
  }

  // FUNCTIONS

  void _init() async {
    // SETTINGS
    await instance.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: 10.seconds,
      minimumFetchInterval: kDebugMode ? 0.seconds : 1.hours,
    ));

    // DEFAULTS
    Map<String, dynamic> parametersMap = {};

    for (var e in parameters) {
      parametersMap.addAll({e: await _obtainLocalParameter(e)});
    }

    await instance.setDefaults(parametersMap);

    // pre-populate to make sure
    _populate();
    // workaround for https://github.com/firebase/flutterfire/issues/6196
    await Future.delayed(2.seconds);
    fetch();
  }

  void _populate() async {
    general = ConfigGeneral.fromJson(
      jsonDecode(instance.getString('general_config')),
    );

    app = ConfigApp.fromJson(jsonDecode(instance.getString('app_config')));
    s3 = ConfigS3.fromJson(jsonDecode(instance.getString('s3_config')));

    choicesCountry = List<HiveLisoFieldChoices>.from(
      jsonDecode(instance.getString('choices_country')).map(
        (x) => HiveLisoFieldChoices.fromJson(x),
      ),
    );

    // TEMPLATES
    templateAPICredential = await _parseTemplate('template_api_credential');
    templateBankAccount = await _parseTemplate('template_bank_account');
    templateCashCard = await _parseTemplate('template_cash_card');
    templateCryptoWallet = await _parseTemplate('template_crypto_wallet');
    templateDatabase = await _parseTemplate('template_database');
    templateDriversLicense = await _parseTemplate('template_drivers_license');
    templateEmailAccount = await _parseTemplate('template_email_account');
    templateEncryption = await _parseTemplate('template_encryption');
    templateIdentity = await _parseTemplate('template_identity');
    templateLogin = await _parseTemplate('template_login');
    templateMedicalRecord = await _parseTemplate('template_medical_record');
    templateMembership = await _parseTemplate('template_membership');
    templateNote = await _parseTemplate('template_note');
    templateOutdoorLicense = await _parseTemplate('template_outdoor_license');
    templatePassport = await _parseTemplate('template_passport');
    templatePassword = await _parseTemplate('template_password');
    templateRewardsProgram = await _parseTemplate('template_rewards_program');
    templateServer = await _parseTemplate('template_server');
    templateSocialSecurity = await _parseTemplate('template_social_security');
    templateSoftwareLicense = await _parseTemplate('template_software_license');
    templateWirelessRouter = await _parseTemplate('template_wireless_router');
  }

  Future<void> fetch() async {
    console.info('fetching...');

    try {
      final updated = await instance.fetchAndActivate();
      console.info('fetched! updated: $updated');
      _populate();
    } catch (e) {
      console.error('fetch error: $e');
    }
  }

  Future<List<HiveLisoField>> _parseTemplate(String key,
      {bool local = false}) async {
    final string =
        local ? await _obtainLocalParameter(key) : _obtainServerParameter(key);

    return List<HiveLisoField>.from(
      jsonDecode(string).map((e) => HiveLisoField.fromJson(e)),
    );
  }

  Future<String> _obtainLocalParameter(String key) async {
    final path = join('assets', 'json', 'config');
    final string = await rootBundle.loadString(join(path, '$key.json'));
    if (string.isEmpty) throw 'empty local config parameter: $key';
    return string; // TODO: error handling
  }

  String _obtainServerParameter(String key) {
    final string = instance.getString(key);
    if (string.isEmpty) throw 'empty server config parameter: $key';
    return string; // TODO: error handling
  }
}
