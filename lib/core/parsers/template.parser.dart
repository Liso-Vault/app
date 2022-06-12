import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';

import '../hive/models/field.hive.dart';
import '../utils/globals.dart';

class TemplateParser {
  static List<HiveLisoField> parse(String category) {
    final config = Get.find<ConfigService>();

    // CRYPTO WALLET
    if (category == LisoItemCategory.cryptoWallet.name) {
      return config.templateCryptoWallet;
    }
    // LOGIN
    else if (category == LisoItemCategory.login.name) {
      return config.templateLogin;
    }
    // PASSWORD
    else if (category == LisoItemCategory.password.name) {
      return config.templatePassword;
    }
    // IDENTITY
    else if (category == LisoItemCategory.identity.name) {
      return config.templateIdentity;
    }
    // NOTE
    else if (category == LisoItemCategory.note.name) {
      return config.templateNote;
    }
    // CASH CARD
    else if (category == LisoItemCategory.cashCard.name) {
      return config.templateCashCard;
    }
    // BANK ACCOUNT
    else if (category == LisoItemCategory.bankAccount.name) {
      return config.templateBankAccount;
    }
    // MEDICAL RECORDS
    else if (category == LisoItemCategory.medicalRecord.name) {
      return config.templateMedicalRecord;
    }
    // PASSPORT
    else if (category == LisoItemCategory.passport.name) {
      return config.templatePassport;
    }
    // SERVER
    else if (category == LisoItemCategory.server.name) {
      return config.templateServer;
    }
    // SOFTWARE LICENSE
    else if (category == LisoItemCategory.softwareLicense.name) {
      return config.templateSoftwareLicense;
    }
    // API CREDENTIAL
    else if (category == LisoItemCategory.apiCredential.name) {
      return config.templateAPICredential;
    }
    // DATABASE
    else if (category == LisoItemCategory.database.name) {
      return config.templateDatabase;
    }
    // DRIVER'S LICENSE
    else if (category == LisoItemCategory.driversLicense.name) {
      return config.templateDriversLicense;
    }
    // EMAIL
    else if (category == LisoItemCategory.email.name) {
      return config.templateEmailAccount;
    }
    // MEMBERSHIP
    else if (category == LisoItemCategory.membership.name) {
      return config.templateMembership;
    }
    // OUTDOOR LICENSE
    else if (category == LisoItemCategory.outdoorLicense.name) {
      return config.templateOutdoorLicense;
    }
    // REWARDS PROGRAM
    else if (category == LisoItemCategory.rewardsProgram.name) {
      return config.templateRewardsProgram;
    }
    // SOCIAL SECURITY
    else if (category == LisoItemCategory.socialSecurity.name) {
      return config.templateSocialSecurity;
    }
    // WIRELESS ROUTER
    else if (category == LisoItemCategory.wirelessRouter.name) {
      return config.templateWirelessRouter;
    }
    // ENCRYPTION
    else if (category == LisoItemCategory.encryption.name) {
      return config.templateEncryption;
    } else {
      return config.templateNote;
    }
  }
}
