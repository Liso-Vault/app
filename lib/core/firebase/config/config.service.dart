import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/features/s3/s3.service.dart';

import '../../hive/models/field.hive.dart';
import '../../utils/globals.dart';
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
    // pre-populate top configs
    _populateTopConfigs(local: true);

    if (!isFirebaseSupported) {
      _populate(local: true);
      return console.warning('Not Supported');
    }

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
    await Future.delayed(3.seconds);
    fetch();
  }

  Future<void> _populateTopConfigs({bool local = false}) async {
    general = ConfigGeneral.fromJson(jsonDecode(await _getString(
      'general_config',
      local: local,
    )));

    app = ConfigApp.fromJson(jsonDecode(await _getString(
      'app_config',
      local: local,
    )));

    s3 = ConfigS3.fromJson(jsonDecode(await _getString(
      's3_config',
      local: local,
    )));
  }

  void _populate({bool local = false}) async {
    _populateTopConfigs(local: local);

    choicesCountry = List<HiveLisoFieldChoices>.from(
      jsonDecode(await _getString('choices_country', local: local)).map(
        (x) => HiveLisoFieldChoices.fromJson(x),
      ),
    );

    // TEMPLATES
    templateAPICredential = await _parseTemplate(
      'template_api_credential',
      local: local,
    );

    templateBankAccount = await _parseTemplate(
      'template_bank_account',
      local: local,
    );

    templateCashCard = await _parseTemplate(
      'template_cash_card',
      local: local,
    );

    templateCryptoWallet = await _parseTemplate(
      'template_crypto_wallet',
      local: local,
    );

    templateDatabase = await _parseTemplate(
      'template_database',
      local: local,
    );

    templateDriversLicense = await _parseTemplate(
      'template_drivers_license',
      local: local,
    );

    templateEmailAccount = await _parseTemplate(
      'template_email_account',
      local: local,
    );

    templateEncryption = await _parseTemplate(
      'template_encryption',
      local: local,
    );

    templateIdentity = await _parseTemplate(
      'template_identity',
      local: local,
    );

    templateLogin = await _parseTemplate(
      'template_login',
      local: local,
    );

    templateMedicalRecord = await _parseTemplate(
      'template_medical_record',
      local: local,
    );

    templateMembership = await _parseTemplate(
      'template_membership',
      local: local,
    );

    templateNote = await _parseTemplate(
      'template_note',
      local: local,
    );

    templateOutdoorLicense = await _parseTemplate(
      'template_outdoor_license',
      local: local,
    );

    templatePassport = await _parseTemplate(
      'template_passport',
      local: local,
    );

    templatePassword = await _parseTemplate(
      'template_password',
      local: local,
    );

    templateRewardsProgram = await _parseTemplate(
      'template_rewards_program',
      local: local,
    );

    templateServer = await _parseTemplate(
      'template_server',
      local: local,
    );

    templateSocialSecurity = await _parseTemplate(
      'template_social_security',
      local: local,
    );

    templateSoftwareLicense = await _parseTemplate(
      'template_software_license',
      local: local,
    );

    templateWirelessRouter = await _parseTemplate(
      'template_wireless_router',
      local: local,
    );

    S3Service.to.init();
    console.info('populated');
  }

  Future<void> fetch() async {
    if (!isFirebaseSupported) return console.warning('Not Supported');
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
    final string = await _getString(key, local: local);

    return List<HiveLisoField>.from(
      jsonDecode(string).map((e) => HiveLisoField.fromJson(e)),
    );
  }

  Future<String> _getString(String key, {bool local = false}) async {
    return local
        ? await _obtainLocalParameter(key)
        : _obtainServerParameter(key);
  }

  Future<String> _obtainLocalParameter(String key) async {
    // we don't use 'path' lib because of a bug for windows
    final string = await rootBundle.loadString('assets/json/config/$key.json');
    if (string.isEmpty) throw 'empty local config parameter: $key';
    return string; // TODO: error handling
  }

  String _obtainServerParameter(String key) {
    final string = instance.getString(key);
    if (string.isEmpty) throw 'empty server config parameter: $key';
    return string; // TODO: error handling
  }
}
