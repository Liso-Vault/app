import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/models/config_web3.model.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:secrets/secrets.dart';

import '../../hive/models/field.hive.dart';
import '../../utils/globals.dart';
import 'models/config_app.model.dart';
import 'models/config_general.model.dart';
import 'models/config_limits.model.dart';
import 'models/config_s3.model.dart';
import 'models/config_users.model.dart';

class ConfigService extends GetxService with ConsoleMixin {
  static ConfigService get to => Get.find();

  // VARIABLES
  var general = const ConfigGeneral();
  var app = const ConfigApp();
  var s3 = const ConfigS3();
  var web3 = const ConfigWeb3();
  var limits = const ConfigLimits();
  var users = const ConfigUsers();

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

  // GETTERS
  FirebaseRemoteConfig get instance => FirebaseRemoteConfig.instance;
  String get appName => general.app.name;
  String get devName => general.developer.name;

  // INIT

  // FUNCTIONS
  Future<void> init() async {
    // pre-populate with local as defaults
    await _populate(local: true);
    if (!isFirebaseSupported) return console.warning('Not Supported');

    // SETTINGS
    await instance.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: 10.seconds,
      minimumFetchInterval: kDebugMode ? 0.seconds : 5.minutes,
    ));

    // workaround for https://github.com/firebase/flutterfire/issues/6196
    // Future.delayed(1.seconds).then((_) => fetch());
    fetch();
  }

  Future<void> fetch() async {
    if (!isFirebaseSupported) return console.warning('Not Supported');
    console.info('fetching...');

    try {
      final updated = await instance.fetchAndActivate();
      console.info('fetch updated: $updated');
      await _populate();
    } catch (e) {
      console.error('fetch error: $e');
    }
  }

  Future<void> _populate({bool local = false}) async {
    app = ConfigApp.fromJson(local
        ? Secrets.configs.app
        : jsonDecode(instance.getString('app_config')));

    s3 = ConfigS3.fromJson(local
        ? Secrets.configs.s3
        : jsonDecode(instance.getString('s3_config')));

    web3 = ConfigWeb3.fromJson(local
        ? Secrets.configs.web3
        : jsonDecode(instance.getString('web3_config')));

    limits = ConfigLimits.fromJson(local
        ? Secrets.configs.limits
        : jsonDecode(instance.getString('limits_config')));

    users = ConfigUsers.fromJson(local
        ? Secrets.configs.users
        : jsonDecode(instance.getString('users_config')));

    general = ConfigGeneral.fromJson(local
        ? Secrets.configs.general
        : jsonDecode(instance.getString('general_config')));

    choicesCountry = List<HiveLisoFieldChoices>.from((local
            ? Secrets.countries
            : jsonDecode(instance.getString('choices_country')))
        .map((x) => HiveLisoFieldChoices.fromJson(x)));

    // TEMPLATES
    templateAPICredential = List<HiveLisoField>.from((local
            ? Secrets.templates.apiCredential
            : jsonDecode(instance.getString('template_api_credential')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateBankAccount = List<HiveLisoField>.from((local
            ? Secrets.templates.bankAccount
            : jsonDecode(instance.getString('template_bank_account')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateCashCard = List<HiveLisoField>.from((local
            ? Secrets.templates.cashCard
            : jsonDecode(instance.getString('template_cash_card')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateCryptoWallet = List<HiveLisoField>.from((local
            ? Secrets.templates.cryptoWallet
            : jsonDecode(instance.getString('template_crypto_wallet')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateDatabase = List<HiveLisoField>.from((local
            ? Secrets.templates.database
            : jsonDecode(instance.getString('template_database')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateDriversLicense = List<HiveLisoField>.from((local
            ? Secrets.templates.driversLicense
            : jsonDecode(instance.getString('template_drivers_license')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateEmailAccount = List<HiveLisoField>.from((local
            ? Secrets.templates.emailAccount
            : jsonDecode(instance.getString('template_email_account')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateEncryption = List<HiveLisoField>.from((local
            ? Secrets.templates.encryption
            : jsonDecode(instance.getString('template_encryption')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateIdentity = List<HiveLisoField>.from((local
            ? Secrets.templates.identity
            : jsonDecode(instance.getString('template_identity')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateLogin = List<HiveLisoField>.from((local
            ? Secrets.templates.login
            : jsonDecode(instance.getString('template_login')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateMedicalRecord = List<HiveLisoField>.from((local
            ? Secrets.templates.medicalRecord
            : jsonDecode(instance.getString('template_medical_record')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateMembership = List<HiveLisoField>.from((local
            ? Secrets.templates.membership
            : jsonDecode(instance.getString('template_membership')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateNote = List<HiveLisoField>.from((local
            ? Secrets.templates.note
            : jsonDecode(instance.getString('template_note')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateOutdoorLicense = List<HiveLisoField>.from((local
            ? Secrets.templates.outdoorLicense
            : jsonDecode(instance.getString('template_outdoor_license')))
        .map((x) => HiveLisoField.fromJson(x)));

    templatePassport = List<HiveLisoField>.from((local
            ? Secrets.templates.passport
            : jsonDecode(instance.getString('template_passport')))
        .map((x) => HiveLisoField.fromJson(x)));

    templatePassword = List<HiveLisoField>.from((local
            ? Secrets.templates.password
            : jsonDecode(instance.getString('template_password')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateRewardsProgram = List<HiveLisoField>.from((local
            ? Secrets.templates.rewardsProgram
            : jsonDecode(instance.getString('template_rewards_program')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateServer = List<HiveLisoField>.from((local
            ? Secrets.templates.server
            : jsonDecode(instance.getString('template_server')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateSocialSecurity = List<HiveLisoField>.from((local
            ? Secrets.templates.socialSecurity
            : jsonDecode(instance.getString('template_social_security')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateSoftwareLicense = List<HiveLisoField>.from((local
            ? Secrets.templates.softwareLicense
            : jsonDecode(instance.getString('template_software_license')))
        .map((x) => HiveLisoField.fromJson(x)));

    templateWirelessRouter = List<HiveLisoField>.from((local
            ? Secrets.templates.wirelessRouter
            : jsonDecode(instance.getString('template_wireless_router')))
        .map((x) => HiveLisoField.fromJson(x)));

    console.info('populated! local: $local');
    // re-init s3 minio client
    S3Service.to.init();
  }
}
