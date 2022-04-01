import 'package:liso/core/templates/api_credential.template.dart';
import 'package:liso/core/templates/bank_account.template.dart';
import 'package:liso/core/templates/cash_card.template.dart';
import 'package:liso/core/templates/crypto_wallet.template.dart';
import 'package:liso/core/templates/database.template.dart';
import 'package:liso/core/templates/drivers_license.template.dart';
import 'package:liso/core/templates/email.template.dart';
import 'package:liso/core/templates/encryption.template.dart';
import 'package:liso/core/templates/identity.template.dart';
import 'package:liso/core/templates/login.template.dart';
import 'package:liso/core/templates/medical_record.template.dart';
import 'package:liso/core/templates/membership.template.dart';
import 'package:liso/core/templates/note.template.dart';
import 'package:liso/core/templates/outdoor_license.template.dart';
import 'package:liso/core/templates/passport.template.dart';
import 'package:liso/core/templates/password.template.dart';
import 'package:liso/core/templates/rewards_program.template.dart';
import 'package:liso/core/templates/server.template.dart';
import 'package:liso/core/templates/social_security.template.dart';
import 'package:liso/core/templates/software_license.template.dart';
import 'package:liso/core/templates/wireless_router.template.dart';

import '../hive/models/field.hive.dart';
import '../utils/globals.dart';

class TemplateParser {
  static List<HiveLisoField> parse(String template) {
    // CRYPTO WALLET
    if (template == LisoItemCategory.cryptoWallet.name) {
      return templateCryptoWalletFields;
    }
    // LOGIN
    else if (template == LisoItemCategory.login.name) {
      return templateLoginFields;
    }
    // PASSWORD
    else if (template == LisoItemCategory.password.name) {
      return templatePasswordFields;
    }
    // IDENTITY
    else if (template == LisoItemCategory.identity.name) {
      return templateIdentityFields;
    }
    // NOTE
    else if (template == LisoItemCategory.note.name) {
      return templateNoteFields;
    }
    // CASH CARD
    else if (template == LisoItemCategory.cashCard.name) {
      return templateCashCardFields;
    }
    // BANK ACCOUNT
    else if (template == LisoItemCategory.bankAccount.name) {
      return templateBankAccountFields;
    }
    // MEDICAL RECORDS
    else if (template == LisoItemCategory.medicalRecord.name) {
      return templateMedicalRecordFields;
    }
    // PASSPORT
    else if (template == LisoItemCategory.passport.name) {
      return templatePassportFields;
    }
    // SERVER
    else if (template == LisoItemCategory.server.name) {
      return templateServerFields;
    }
    // SOFTWARE LICENSE
    else if (template == LisoItemCategory.softwareLicense.name) {
      return templateSoftwareLicenseFields;
    }
    // API CREDENTIAL
    else if (template == LisoItemCategory.apiCredential.name) {
      return templateAPICredentialFields;
    }
    // DATABASE
    else if (template == LisoItemCategory.database.name) {
      return templateDatabaseFields;
    }
    // DRIVER'S LICENSE
    else if (template == LisoItemCategory.driversLicense.name) {
      return templateDriversLicenseFields;
    }
    // EMAIL
    else if (template == LisoItemCategory.email.name) {
      return templateEmailFields;
    }
    // MEMBERSHIP
    else if (template == LisoItemCategory.membership.name) {
      return templateMembershipFields;
    }
    // OUTDOOR LICENSE
    else if (template == LisoItemCategory.outdoorLicense.name) {
      return templateOutdoorLicenseFields;
    }
    // REWARDS PROGRAM
    else if (template == LisoItemCategory.rewardsProgram.name) {
      return templateRewardsProgramFields;
    }
    // SOCIAL SECURITY
    else if (template == LisoItemCategory.socialSecurity.name) {
      return templateSocialSecurityFields;
    }
    // WIRELESS ROUTER
    else if (template == LisoItemCategory.wirelessRouter.name) {
      return templateWirelessRouterFields;
    }
    // ENCRYPTION
    else if (template == LisoItemCategory.encryption.name) {
      return templateEncryptionFields;
    }

    // UNKNOWN TEMPLATE
    throw 'Failed to parse unknown template: $template';
  }
}
