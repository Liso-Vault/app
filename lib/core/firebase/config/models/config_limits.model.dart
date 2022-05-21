class ConfigLimits {
  const ConfigLimits({
    this.tier1 = const ConfigLimitsSetting(),
    this.tier2 = const ConfigLimitsSetting(),
    this.tier3 = const ConfigLimitsSetting(),
    this.tier4 = const ConfigLimitsSetting(),
  });

  final ConfigLimitsSetting tier1;
  final ConfigLimitsSetting tier2;
  final ConfigLimitsSetting tier3;
  final ConfigLimitsSetting tier4;

  factory ConfigLimits.fromJson(Map<String, dynamic> json) => ConfigLimits(
        tier1: ConfigLimitsSetting.fromJson(json["tier1"]),
        tier2: ConfigLimitsSetting.fromJson(json["tier2"]),
        tier3: ConfigLimitsSetting.fromJson(json["tier3"]),
        tier4: ConfigLimitsSetting.fromJson(json["tier4"]),
      );

  Map<String, dynamic> toJson() => {
        "tier1": tier1.toJson(),
        "tier2": tier2.toJson(),
        "tier3": tier3.toJson(),
        "tier4": tier4.toJson(),
      };
}

class ConfigLimitsSetting {
  const ConfigLimitsSetting({
    this.tokenThreshold = 0,
    this.storageSize = 0,
    this.uploadSize = 0,
    this.items = 0,
    this.files = 0,
    this.backups = 0,
    this.devices = 0,
    this.trashDays = 0,
    this.protectedItems = 0,
    this.sharedDevices = 0,
    this.addVaults = false,
    this.fileEncryption = false,
    this.breachScanner = false,
    this.passwordHealth = false,
    this.nfcKeycard = false,
    this.prioritySupport = false,
  });

  final int tokenThreshold;
  final int storageSize;
  final int uploadSize;
  final int items;
  final int files;
  final int backups;
  final int devices;
  final int trashDays;
  final int protectedItems;
  final int sharedDevices;
  final bool addVaults;
  final bool fileEncryption;
  final bool breachScanner;
  final bool passwordHealth;
  final bool nfcKeycard;
  final bool prioritySupport;

  factory ConfigLimitsSetting.fromJson(Map<String, dynamic> json) =>
      ConfigLimitsSetting(
        tokenThreshold: json["token_threshold"],
        storageSize: json["storage_size"],
        uploadSize: json["upload_size"],
        items: json["items"],
        files: json["files"],
        backups: json["backups"],
        devices: json["devices"],
        trashDays: json["trash_days"],
        protectedItems: json["protected_items"],
        sharedDevices: json["shared_devices"],
        addVaults: json["add_vaults"],
        fileEncryption: json["file_encryption"],
        breachScanner: json["breach_scanner"],
        passwordHealth: json["password_health"],
        nfcKeycard: json["nfc_keycard"],
        prioritySupport: json["priority_support"],
      );

  Map<String, dynamic> toJson() => {
        "token_threshold": tokenThreshold,
        "storage_size": storageSize,
        "upload_size": uploadSize,
        "items": items,
        "files": files,
        "backups": backups,
        "devices": devices,
        "trash_days": trashDays,
        "protected_items": protectedItems,
        "shared_devices": sharedDevices,
        "add_vaults": addVaults,
        "file_encryption": fileEncryption,
        "breach_scanner": breachScanner,
        "password_health": passwordHealth,
        "nfc_keycard": nfcKeycard,
        "priority_support": prioritySupport,
      };
}
