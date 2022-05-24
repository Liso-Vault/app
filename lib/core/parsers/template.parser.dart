import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';

import '../hive/models/field.hive.dart';
import '../utils/globals.dart';

class TemplateParser {
  static List<HiveLisoField> parse(String template) {
    final config = Get.find<ConfigService>();

    // CRYPTO WALLET
    if (template == LisoItemCategory.cryptoWallet.name) {
      return config.templateCryptoWallet;
    }
    // LOGIN
    else if (template == LisoItemCategory.login.name) {
      return config.templateLogin;
    }
    // PASSWORD
    else if (template == LisoItemCategory.password.name) {
      return config.templatePassword;
    }
    // IDENTITY
    else if (template == LisoItemCategory.identity.name) {
      return config.templateIdentity;
    }
    // NOTE
    else if (template == LisoItemCategory.note.name) {
      return config.templateNote;
    }
    // CASH CARD
    else if (template == LisoItemCategory.cashCard.name) {
      return config.templateCashCard;
    }
    // BANK ACCOUNT
    else if (template == LisoItemCategory.bankAccount.name) {
      return config.templateBankAccount;
    }
    // MEDICAL RECORDS
    else if (template == LisoItemCategory.medicalRecord.name) {
      return config.templateMedicalRecord;
    }
    // PASSPORT
    else if (template == LisoItemCategory.passport.name) {
      return config.templatePassport;
    }
    // SERVER
    else if (template == LisoItemCategory.server.name) {
      return config.templateServer;
    }
    // SOFTWARE LICENSE
    else if (template == LisoItemCategory.softwareLicense.name) {
      return config.templateSoftwareLicense;
    }
    // API CREDENTIAL
    else if (template == LisoItemCategory.apiCredential.name) {
      return config.templateAPICredential;
    }
    // DATABASE
    else if (template == LisoItemCategory.database.name) {
      return config.templateDatabase;
    }
    // DRIVER'S LICENSE
    else if (template == LisoItemCategory.driversLicense.name) {
      return config.templateDriversLicense;
    }
    // EMAIL
    else if (template == LisoItemCategory.email.name) {
      return config.templateEmailAccount;
    }
    // MEMBERSHIP
    else if (template == LisoItemCategory.membership.name) {
      return config.templateMembership;
    }
    // OUTDOOR LICENSE
    else if (template == LisoItemCategory.outdoorLicense.name) {
      return config.templateOutdoorLicense;
    }
    // REWARDS PROGRAM
    else if (template == LisoItemCategory.rewardsProgram.name) {
      return config.templateRewardsProgram;
    }
    // SOCIAL SECURITY
    else if (template == LisoItemCategory.socialSecurity.name) {
      return config.templateSocialSecurity;
    }
    // WIRELESS ROUTER
    else if (template == LisoItemCategory.wirelessRouter.name) {
      return config.templateWirelessRouter;
    }
    // ENCRYPTION
    else if (template == LisoItemCategory.encryption.name) {
      return config.templateEncryption;
    }

    // UNKNOWN TEMPLATE
    throw 'Failed to parse unknown template: $template';
  }
}
