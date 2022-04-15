import 'dart:convert';

class ConfigGlobal {
  const ConfigGlobal({
    this.developer = const ConfigGlobalDeveloper(),
    this.client = const ConfigGlobalClient(),
  });

  final ConfigGlobalDeveloper developer;
  final ConfigGlobalClient client;

  factory ConfigGlobal.fromJson(Map<String, dynamic> json) => ConfigGlobal(
        developer: ConfigGlobalDeveloper.fromJson(json["developer"]),
        client: ConfigGlobalClient.fromJson(json["client"]),
      );

  Map<String, dynamic> toJson() => {
        "developer": developer.toJson(),
        "client": client.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());
}

class ConfigGlobalClient {
  const ConfigGlobalClient({
    this.links = const ConfigGlobalClientLinks(),
  });

  final ConfigGlobalClientLinks links;

  factory ConfigGlobalClient.fromJson(Map<String, dynamic> json) =>
      ConfigGlobalClient(
        links: ConfigGlobalClientLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "links": links.toJson(),
      };
}

class ConfigGlobalClientLinks {
  const ConfigGlobalClientLinks({
    this.privacy = '',
    this.terms = '',
    this.faqs = '',
  });

  final String privacy;
  final String terms;
  final String faqs;

  factory ConfigGlobalClientLinks.fromJson(Map<String, dynamic> json) =>
      ConfigGlobalClientLinks(
        privacy: json["privacy"],
        terms: json["terms"],
        faqs: json["faqs"],
      );

  Map<String, dynamic> toJson() => {
        "privacy": privacy,
        "terms": terms,
        "faqs": faqs,
      };
}

class ConfigGlobalDeveloper {
  const ConfigGlobalDeveloper({
    this.name = 'Stackwares',
    this.email = 'support@stackwares.com',
    this.logo = '',
    this.address = const ConfigGlobalAddress(),
    this.links = const ConfigGlobalDeveloperLinks(),
  });

  final String name;
  final String email;
  final String logo;
  final ConfigGlobalAddress address;
  final ConfigGlobalDeveloperLinks links;

  factory ConfigGlobalDeveloper.fromJson(Map<String, dynamic> json) =>
      ConfigGlobalDeveloper(
        name: json["name"],
        email: json["email"],
        logo: json["logo"],
        address: ConfigGlobalAddress.fromJson(json["address"]),
        links: ConfigGlobalDeveloperLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "logo": logo,
        "address": address.toJson(),
        "links": links.toJson(),
      };
}

class ConfigGlobalAddress {
  const ConfigGlobalAddress({
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

  factory ConfigGlobalAddress.fromJson(Map<String, dynamic> json) =>
      ConfigGlobalAddress(
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

class ConfigGlobalDeveloperLinks {
  const ConfigGlobalDeveloperLinks({
    this.website = 'https://stackwares.com',
    this.twitter = 'https://twitter.com/stackwares',
    this.facebook = 'https://stackwares.com',
    this.instagram = 'https://stackwares.com',
    this.linkedin = 'https://stackwares.com',
    this.discord = 'https://stackwares.com',
    this.github = 'https://stackwares.com',
    this.privacy = 'https://stackwares.com',
    this.store = const ConfigGlobalStore(),
  });

  final String website;
  final String twitter;
  final String facebook;
  final String instagram;
  final String linkedin;
  final String discord;
  final String github;
  final String privacy;
  final ConfigGlobalStore store;

  factory ConfigGlobalDeveloperLinks.fromJson(Map<String, dynamic> json) =>
      ConfigGlobalDeveloperLinks(
        website: json["website"],
        twitter: json["twitter"],
        facebook: json["facebook"],
        instagram: json["instagram"],
        linkedin: json["linkedin"],
        discord: json["discord"],
        github: json["github"],
        privacy: json["privacy"],
        store: ConfigGlobalStore.fromJson(json["store"]),
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

class ConfigGlobalStore {
  const ConfigGlobalStore({
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

  factory ConfigGlobalStore.fromJson(Map<String, dynamic> json) =>
      ConfigGlobalStore(
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
