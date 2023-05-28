import 'package:secrets/secrets.dart';

const kExtraJson = {
  "secrets": {
    "s3": {"key": "", "secret": "", "bucket": "", "endpoint": ""},
    "alchemy": {"apiKey": ""}
  },
  "web3": Secrets.web3,
  "appDomains": Secrets.appDomains
};

const kAppJson = {
  "name": "Liso",
  "dev": "Stackwares",
  "build": {
    "min": 1,
    "latest": 1,
    "beta": [1, 2, 3],
    "disabled": [0]
  },
  "emails": {
    "support": "dev@liso.dev",
    "issues": "dev@liso.dev",
    "translations": "dev@liso.dev",
    "premium": "dev@liso.dev"
  },
  "links": {
    "website": "https://liso.dev",
    "twitter": "https://twitter.com/liso_vault",
    "facebook": "https://facebook.com/nextranapp",
    "facebook_group": "https://www.facebook.com/groups/433497115508547/",
    "instagram": "https://instagram.com/nextranapp",
    "discord": "https://liso.dev",
    "faqs": "https://liso.super.site/faqs",
    "roadmap": "https://liso.super.site/roadmap",
    "reddit": "xxx",
    "product_hunt": "",
    "tutorials": "https://liso.super.site/tutorials",
    "contributors": "https://liso.super.site/contributors",
    "privacy": "https://liso.super.site/privacy",
    "terms": "https://liso.super.site/terms",
    "giveaway": "https://liso.super.site/giveaway",
    "translations": "https://localazy.com/p/nextran",
    "affiliates": "https://oliverbytes.gumroad.com/affiliates",
    "store": {
      "google": "https://play.google.com/store/apps/details?id=com.liso.app",
      "apple": "https://apps.apple.com/us/app/nextran/id1621225567",
      "amazon": "https://stackwares.com",
      "samsung": "https://stackwares.com",
      "huawei": "https://stackwares.com",
      "gumroad": "https://oliverbytes.gumroad.com/l/liso-pro"
    }
  }
};

const kSecretJson = Secrets.secrets;

const kLicenseJson = {
  "pro": {
    "id": "pro",
    "files": 1000000,
    "items": 1000000,
    "backups": 200,
    "devices": 1000000,
    "trash_days": 365,
    "cipher_tool": true,
    "nfc_keycard": true,
    "upload_size": 838860800,
    "storage_size": 1073741824,
    "custom_vaults": 1000000,
    "otp_generator": true,
    "shared_vaults": 1000000,
    "breach_scanner": true,
    "shared_members": 1000000,
    "encrypted_files": 1000000,
    "password_health": true,
    "protected_items": 1000000,
    "token_threshold": 0,
    "priority_support": true,
    "custom_categories": 1000000
  },
  "holder": {
    "id": "holder",
    "token_threshold": 1000,
    "storage_size": 209715200,
    "upload_size": 167772160,
    "items": 200,
    "files": 20,
    "backups": 10,
    "devices": 10,
    "trash_days": 30,
    "protected_items": 20,
    "shared_members": 10,
    "shared_vaults": 10,
    "custom_vaults": 10,
    "custom_categories": 10,
    "encrypted_files": 1000000,
    "breach_scanner": false,
    "password_health": false,
    "nfc_keycard": false,
    "cipher_tool": false,
    "otp_generator": false,
    "priority_support": false
  },
  "free": {
    "id": "free",
    "files": 10,
    "items": 100,
    "backups": 2,
    "devices": 5,
    "trash_days": 5,
    "cipher_tool": false,
    "nfc_keycard": false,
    "upload_size": 83886080,
    "storage_size": 104857600,
    "custom_vaults": 5,
    "otp_generator": false,
    "shared_vaults": 5,
    "breach_scanner": false,
    "shared_members": 5,
    "encrypted_files": 1000000,
    "password_health": false,
    "protected_items": 5,
    "token_threshold": 0,
    "priority_support": false,
    "custom_categories": 5
  }
};
