import 'package:secrets/secrets.dart';

const kExtraJson = {
  "secrets": {
    "s3": {
      "key": "",
      "secret": "",
      "bucket": "liso-sia",
      "endpoint": "s3.filebase.com"
    },
    "alchemy": {"apiKey": ""}
  },
  "web3": {
    "chains": [
      {
        "name": "Polygon",
        "symbol": "MATIC",
        "decimals": 18,
        "logo": "",
        "main": {"http": "", "ws": ""},
        "test": {"http": "", "ws": ""}
      }
    ]
  }
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

final kSecretJson = {
  "persistence": {
    "box": "persistence",
    "key": Secrets.persistenceKey,
  },
  "revenuecat": Secrets.secrets['revenuecat'],
  "sentry": {
    "dsn": Secrets.secrets['sentry']!['dsn'] as String,
  },
  "supabase": Secrets.secrets['supabase'],
};

const kLicenseJson = {
  "business": {
    "id": "business",
    "users": 1,
    "edits": 10000,
    "devices": 1,
  },
  "max": {
    "id": "max",
    "users": 1,
    "edits": 5000,
    "devices": 1,
  },
  "pro": {
    "id": "pro",
    "users": 1,
    "edits": 1000,
    "devices": 1,
  },
  "plus": {
    "id": "plus",
    "users": 1,
    "edits": 500,
    "devices": 1,
  },
  "starter": {
    "id": "starter",
    "users": 1,
    "edits": 250,
    "devices": 1,
  },
  "free": {
    "id": "free",
    "users": 1,
    "edits": 20,
    "devices": 1,
  },
};
