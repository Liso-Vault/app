import 'package:liso/core/firebase/config/config.service.dart';

import '../hive/models/field.hive.dart';
import '../utils/globals.dart';

class TemplateParser {
  static List<HiveLisoField> parse(String template) {
    // CRYPTO WALLET
    if (template == LisoItemCategory.cryptoWallet.name) {
      return ConfigService.to.templateCryptoWallet;
    }
    // LOGIN
    else if (template == LisoItemCategory.login.name) {
      return ConfigService.to.templateLogin;
    }
    // PASSWORD
    else if (template == LisoItemCategory.password.name) {
      return ConfigService.to.templatePassword;
    }
    // IDENTITY
    else if (template == LisoItemCategory.identity.name) {
      return ConfigService.to.templateIdentity;
    }
    // NOTE
    else if (template == LisoItemCategory.note.name) {
      return ConfigService.to.templateNote;
    }
    // CASH CARD
    else if (template == LisoItemCategory.cashCard.name) {
      return ConfigService.to.templateCashCard;
    }
    // BANK ACCOUNT
    else if (template == LisoItemCategory.bankAccount.name) {
      return ConfigService.to.templateBankAccount;
    }
    // MEDICAL RECORDS
    else if (template == LisoItemCategory.medicalRecord.name) {
      return ConfigService.to.templateMedicalRecord;
    }
    // PASSPORT
    else if (template == LisoItemCategory.passport.name) {
      return ConfigService.to.templatePassport;
    }
    // SERVER
    else if (template == LisoItemCategory.server.name) {
      return ConfigService.to.templateServer;
    }
    // SOFTWARE LICENSE
    else if (template == LisoItemCategory.softwareLicense.name) {
      return ConfigService.to.templateSoftwareLicense;
    }
    // API CREDENTIAL
    else if (template == LisoItemCategory.apiCredential.name) {
      return ConfigService.to.templateAPICredential;
    }
    // DATABASE
    else if (template == LisoItemCategory.database.name) {
      return ConfigService.to.templateDatabase;
    }
    // DRIVER'S LICENSE
    else if (template == LisoItemCategory.driversLicense.name) {
      return ConfigService.to.templateDriversLicense;
    }
    // EMAIL
    else if (template == LisoItemCategory.email.name) {
      return ConfigService.to.templateEmailAccount;
    }
    // MEMBERSHIP
    else if (template == LisoItemCategory.membership.name) {
      return ConfigService.to.templateMembership;
    }
    // OUTDOOR LICENSE
    else if (template == LisoItemCategory.outdoorLicense.name) {
      return ConfigService.to.templateOutdoorLicense;
    }
    // REWARDS PROGRAM
    else if (template == LisoItemCategory.rewardsProgram.name) {
      return ConfigService.to.templateRewardsProgram;
    }
    // SOCIAL SECURITY
    else if (template == LisoItemCategory.socialSecurity.name) {
      return ConfigService.to.templateSocialSecurity;
    }
    // WIRELESS ROUTER
    else if (template == LisoItemCategory.wirelessRouter.name) {
      return ConfigService.to.templateWirelessRouter;
    }
    // ENCRYPTION
    else if (template == LisoItemCategory.encryption.name) {
      return ConfigService.to.templateEncryption;
    }

    // UNKNOWN TEMPLATE
    throw 'Failed to parse unknown template: $template';
  }
}
