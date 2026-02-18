import 'package:app_core/firebase/config.service.dart';
import 'package:app_core/firebase/model/emails.model.dart';
import 'package:app_core/firebase/model/general.model.dart';
import 'package:app_core/firebase/model/links.model.dart';
import 'package:app_core/firebase/model/versions.model.dart';

void initConfigDefaults() {
  final generalMap = {"name": "Liso", "developer": "Stackwares"};

  final versionsMap = {
    "min": 68,
    "beta": [0],
    "latest": 68,
    "disabled": [0],
  };

  final emailsMap = {
    "issues": "stackwares+liso@gmail.com",
    "suggestions": "stackwares+liso@gmail.com",
    "feedback": "stackwares+liso@gmail.com",
  };

  final linksMap = {
    "legal": {
      "terms": "https://github.com/Liso-Vault/app/blob/master/TERMS.md",
      "privacy": "https://github.com/Liso-Vault/app/blob/master/PRIVACY.md"
    },
    "store": {
      "huawei": "",
      "amazon": "",
      "samsung": "",
      "web": "",
      "apple":
          "https://apps.apple.com/us/app/aegis-authenticator-2fas-liso/id1621225567",
      "google": "https://play.google.com/store/apps/details?id=com.liso.app"
    },
    "socials": {
      "reddit": "",
      "discord": "",
      "roadmap": "",
      "twitter": "",
      "website": "",
      "facebook": "",
      "instagram": "",
      "facebookGroup": ""
    },
    "others": {
      "faqs": "",
      "giveaway": "",
      "tutorials": "",
      "affiliates": "",
      "website": "https://liso.dev/"
    }
  };

  configExtraMap = {};

  versions = ConfigVersions.fromJson(versionsMap);
  emails = ConfigEmails.fromJson(emailsMap);
  links = ConfigLinks.fromJson(linksMap);
  general = ConfigGeneral.fromJson(generalMap);
}
