import 'package:liso/core/templates/bank_account.template.dart';
import 'package:liso/core/templates/cash_card.template.dart';
import 'package:liso/core/templates/crypto_wallet.template.dart';
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
    if (template == LisoItemType.cryptoWallet.name) {
      return templateCryptoWalletFields;
    }
    // LOGIN
    else if (template == LisoItemType.login.name) {
      return templateLoginFields;
    }
    // PASSWORD
    else if (template == LisoItemType.password.name) {
      return templatePasswordFields;
    }
    // IDENTITY
    else if (template == LisoItemType.identity.name) {
      return templateIdentityFields;
    }
    // NOTE
    else if (template == LisoItemType.note.name) {
      return templateNoteFields;
    }
    // CASH CARD
    else if (template == LisoItemType.cashCard.name) {
      return templateCashCardFields;
    }
    // BANK ACCOUNT
    else if (template == LisoItemType.bankAccount.name) {
      return templateBankAccountFields;
    }
    // MEDICAL RECORDS
    else if (template == LisoItemType.medicalRecord.name) {
      return templateMedicalRecordFields;
    }
    // PASSPORT
    else if (template == LisoItemType.passport.name) {
      return templatePassportFields;
    }
    // SERVER
    else if (template == LisoItemType.server.name) {
      return templateServerFields;
    }
    // SOFTWARE LICENSE
    else if (template == LisoItemType.softwareLicense.name) {
      return templateSoftwareLicenseFields;
    }
    // EMAIL
    else if (template == LisoItemType.email.name) {
      return templateEmailFields;
    }
    // MEMBERSHIP
    else if (template == LisoItemType.membership.name) {
      return templateMembershipFields;
    }
    // OUTDOOR LICENSE
    else if (template == LisoItemType.outdoorLicense.name) {
      return templateOutdoorLicenseFields;
    }
    // REWARDS PROGRAM
    else if (template == LisoItemType.rewardsProgram.name) {
      return templateRewardsProgramFields;
    }
    // SOCIAL SECURITY
    else if (template == LisoItemType.socialSecurity.name) {
      return templateSocialSecurityFields;
    }
    // WIRELESS ROUTER
    else if (template == LisoItemType.wirelessRouter.name) {
      return templateWirelessRouterFields;
    }
    // ENCRYPTION
    else if (template == LisoItemType.encryption.name) {
      return templateEncryptionFields;
    }

    // UNKNOWN TEMPLATE
    throw 'Failed to parse unknown template: $template';
  }
}
