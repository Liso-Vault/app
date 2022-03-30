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
    if (template == LisoReservedTags.cryptoWallet.name) {
      return templateCryptoWalletFields;
    }
    // LOGIN
    else if (template == LisoReservedTags.login.name) {
      return templateLoginFields;
    }
    // PASSWORD
    else if (template == LisoReservedTags.password.name) {
      return templatePasswordFields;
    }
    // IDENTITY
    else if (template == LisoReservedTags.identity.name) {
      return templateIdentityFields;
    }
    // NOTE
    else if (template == LisoReservedTags.note.name) {
      return templateNoteFields;
    }
    // CASH CARD
    else if (template == LisoReservedTags.cashCard.name) {
      return templateCashCardFields;
    }
    // BANK ACCOUNT
    else if (template == LisoReservedTags.bankAccount.name) {
      return templateBankAccountFields;
    }
    // MEDICAL RECORDS
    else if (template == LisoReservedTags.medicalRecord.name) {
      return templateMedicalRecordFields;
    }
    // PASSPORT
    else if (template == LisoReservedTags.passport.name) {
      return templatePassportFields;
    }
    // SERVER
    else if (template == LisoReservedTags.server.name) {
      return templateServerFields;
    }
    // SOFTWARE LICENSE
    else if (template == LisoReservedTags.softwareLicense.name) {
      return templateSoftwareLicenseFields;
    }
    // EMAIL
    else if (template == LisoReservedTags.email.name) {
      return templateEmailFields;
    }
    // MEMBERSHIP
    else if (template == LisoReservedTags.membership.name) {
      return templateMembershipFields;
    }
    // OUTDOOR LICENSE
    else if (template == LisoReservedTags.outdoorLicense.name) {
      return templateOutdoorLicenseFields;
    }
    // REWARDS PROGRAM
    else if (template == LisoReservedTags.rewardsProgram.name) {
      return templateRewardsProgramFields;
    }
    // SOCIAL SECURITY
    else if (template == LisoReservedTags.socialSecurity.name) {
      return templateSocialSecurityFields;
    }
    // WIRELESS ROUTER
    else if (template == LisoReservedTags.wirelessRouter.name) {
      return templateWirelessRouterFields;
    }
    // ENCRYPTION
    else if (template == LisoReservedTags.encryption.name) {
      return templateEncryptionFields;
    }

    // UNKNOWN TEMPLATE
    throw 'Failed to parse unknown template: $template';
  }
}
