import 'dart:convert';

class ConfigGeneral {
  const ConfigGeneral({
    this.developer = const ConfigGeneralDeveloper(),
    this.app = const ConfigGeneralApp(),
  });

  final ConfigGeneralDeveloper developer;
  final ConfigGeneralApp app;

  factory ConfigGeneral.fromJson(Map<String, dynamic> json) => ConfigGeneral(
        developer: ConfigGeneralDeveloper.fromJson(json["developer"]),
        app: ConfigGeneralApp.fromJson(json["app"]),
      );

  Map<String, dynamic> toJson() => {
        "developer": developer.toJson(),
        "app": app.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());
}

class ConfigGeneralApp {
  const ConfigGeneralApp({
    this.name = '',
    this.image = '',
    this.shortDescription = '',
    this.longDescription = '',
    this.shareText = '',
    this.emails = const ConfigGeneralAppEmails(),
    this.links = const ConfigGeneralAppLinks(),
  });

  final String name;
  final String image;
  final String shortDescription;
  final String longDescription;
  final String shareText;
  final ConfigGeneralAppEmails emails;
  final ConfigGeneralAppLinks links;

  factory ConfigGeneralApp.fromJson(Map<String, dynamic> json) =>
      ConfigGeneralApp(
        name: json["name"],
        image: json["image"],
        shortDescription: json["short_description"],
        longDescription: json["long_description"],
        shareText: json["share_text"],
        emails: ConfigGeneralAppEmails.fromJson(json["emails"]),
        links: ConfigGeneralAppLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "short_description": shortDescription,
        "long_description": longDescription,
        "share_text": shareText,
        "emails": emails.toJson(),
        "links": links.toJson(),
      };
}

class ConfigGeneralAppEmails {
  const ConfigGeneralAppEmails({
    this.support = '',
    this.issues = '',
    this.translations = '',
    this.premium = '',
  });

  final String support;
  final String issues;
  final String translations;
  final String premium;

  factory ConfigGeneralAppEmails.fromJson(Map<String, dynamic> json) =>
      ConfigGeneralAppEmails(
        support: json["support"],
        issues: json["issues"],
        translations: json["translations"],
        premium: json["premium"],
      );

  Map<String, dynamic> toJson() => {
        "support": support,
        "issues": issues,
        "translations": translations,
        "premium": premium,
      };
}

class ConfigGeneralAppLinks {
  const ConfigGeneralAppLinks({
    this.website = '',
    this.twitter = '',
    this.facebook = '',
    this.instagram = '',
    this.discord = '',
    this.github = '',
    this.privacy = '',
    this.telegram = '',
    this.matrix = '',
    this.terms = '',
    this.faqs = '',
    this.roadmap = '',
    this.forum = '',
    this.store = const ConfigGeneralStore(),
  });

  final String website;
  final String twitter;
  final String facebook;
  final String instagram;
  final String discord;
  final String github;
  final String privacy;
  final String telegram;
  final String matrix;
  final String terms;
  final String faqs;
  final String roadmap;
  final String forum;
  final ConfigGeneralStore store;

  factory ConfigGeneralAppLinks.fromJson(Map<String, dynamic> json) =>
      ConfigGeneralAppLinks(
        website: json["website"],
        twitter: json["twitter"],
        facebook: json["facebook"],
        instagram: json["instagram"],
        discord: json["discord"],
        github: json["github"],
        privacy: json["privacy"],
        telegram: json["telegram"],
        matrix: json["matrix"],
        terms: json["terms"],
        faqs: json["faqs"],
        roadmap: json["roadmap"],
        forum: json["forum"],
        store: ConfigGeneralStore.fromJson(json["store"]),
      );

  Map<String, dynamic> toJson() => {
        "website": website,
        "twitter": twitter,
        "facebook": facebook,
        "instagram": instagram,
        "discord": discord,
        "github": github,
        "privacy": privacy,
        "telegram": telegram,
        "matrix": matrix,
        "terms": terms,
        "faqs": faqs,
        "roadmap": roadmap,
        "forum": forum,
        "store": store.toJson(),
      };
}

class ConfigGeneralStore {
  const ConfigGeneralStore({
    this.google = '',
    this.apple = '',
    this.amazon = '',
    this.samsung = '',
    this.huawei = '',
  });

  final String google;
  final String apple;
  final String amazon;
  final String samsung;
  final String huawei;

  factory ConfigGeneralStore.fromJson(Map<String, dynamic> json) =>
      ConfigGeneralStore(
        google: json["google"],
        apple: json["apple"],
        amazon: json["amazon"],
        samsung: json["samsung"],
        huawei: json["huawei"],
      );

  Map<String, dynamic> toJson() => {
        "google": google,
        "apple": apple,
        "amazon": amazon,
        "samsung": samsung,
        "huawei": huawei,
      };
}

class ConfigGeneralDeveloper {
  const ConfigGeneralDeveloper({
    this.name = '',
    this.image = '',
    this.shortDescription = '=',
    this.longDescription = '',
    this.address = const ConfigGeneralDeveloperAddress(),
    this.emails = const ConfigGeneralDeveloperEmails(),
    this.links = const ConfigGeneralDeveloperLinks(),
  });

  final String name;
  final String image;
  final String shortDescription;
  final String longDescription;
  final ConfigGeneralDeveloperAddress address;
  final ConfigGeneralDeveloperEmails emails;
  final ConfigGeneralDeveloperLinks links;

  factory ConfigGeneralDeveloper.fromJson(Map<String, dynamic> json) =>
      ConfigGeneralDeveloper(
        name: json["name"],
        image: json["image"],
        shortDescription: json["short_description"],
        longDescription: json["long_description"],
        address: ConfigGeneralDeveloperAddress.fromJson(json["address"]),
        emails: ConfigGeneralDeveloperEmails.fromJson(json["emails"]),
        links: ConfigGeneralDeveloperLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "short_description": shortDescription,
        "long_description": longDescription,
        "address": address.toJson(),
        "emails": emails.toJson(),
        "links": links.toJson(),
      };
}

class ConfigGeneralDeveloperAddress {
  const ConfigGeneralDeveloperAddress({
    this.street1 = '',
    this.street2 = '',
    this.city = '',
    this.state = '',
    this.postal = '',
    this.country = '',
  });

  final String street1;
  final String street2;
  final String city;
  final String state;
  final String postal;
  final String country;

  factory ConfigGeneralDeveloperAddress.fromJson(Map<String, dynamic> json) =>
      ConfigGeneralDeveloperAddress(
        street1: json["street1"],
        street2: json["street2"],
        city: json["city"],
        state: json["state"],
        postal: json["postal"],
        country: json["country"],
      );

  Map<String, dynamic> toJson() => {
        "street1": street1,
        "street2": street2,
        "city": city,
        "state": state,
        "postal": postal,
        "country": country,
      };
}

class ConfigGeneralDeveloperEmails {
  const ConfigGeneralDeveloperEmails({
    this.support = '',
    this.marketing = '',
    this.business = '',
  });

  final String support;
  final String marketing;
  final String business;

  factory ConfigGeneralDeveloperEmails.fromJson(Map<String, dynamic> json) =>
      ConfigGeneralDeveloperEmails(
        support: json["support"],
        marketing: json["marketing"],
        business: json["business"],
      );

  Map<String, dynamic> toJson() => {
        "support": support,
        "marketing": marketing,
        "business": business,
      };
}

class ConfigGeneralDeveloperLinks {
  const ConfigGeneralDeveloperLinks({
    this.website = '',
    this.twitter = '',
    this.facebook = '',
    this.instagram = '',
    this.linkedin = '',
    this.discord = '',
    this.github = '',
    this.privacy = '',
    this.store = const ConfigGeneralStore(),
  });

  final String website;
  final String twitter;
  final String facebook;
  final String instagram;
  final String linkedin;
  final String discord;
  final String github;
  final String privacy;
  final ConfigGeneralStore store;

  factory ConfigGeneralDeveloperLinks.fromJson(Map<String, dynamic> json) =>
      ConfigGeneralDeveloperLinks(
        website: json["website"],
        twitter: json["twitter"],
        facebook: json["facebook"],
        instagram: json["instagram"],
        linkedin: json["linkedin"],
        discord: json["discord"],
        github: json["github"],
        privacy: json["privacy"],
        store: ConfigGeneralStore.fromJson(json["store"]),
      );

  Map<String, dynamic> toJson() => {
        "website": website,
        "twitter": twitter,
        "facebook": facebook,
        "instagram": instagram,
        "linkedin": linkedin,
        "discord": discord,
        "github": github,
        "privacy": privacy,
        "store": store.toJson(),
      };
}
