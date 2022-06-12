class ConfigLimits {
  const ConfigLimits({
    this.tier0 = const ConfigLimitsSetting(),
    this.tier1 = const ConfigLimitsSetting(),
    this.tier2 = const ConfigLimitsSetting(),
    this.tier3 = const ConfigLimitsSetting(),
  });

  final ConfigLimitsSetting tier0;
  final ConfigLimitsSetting tier1;
  final ConfigLimitsSetting tier2;
  final ConfigLimitsSetting tier3;

  factory ConfigLimits.fromJson(Map<String, dynamic> json) => ConfigLimits(
        tier0: ConfigLimitsSetting.fromJson(json["tier0"]),
        tier1: ConfigLimitsSetting.fromJson(json["tier1"]),
        tier2: ConfigLimitsSetting.fromJson(json["tier2"]),
        tier3: ConfigLimitsSetting.fromJson(json["tier3"]),
      );

  Map<String, dynamic> toJson() => {
        "tier0": tier0.toJson(),
        "tier1": tier1.toJson(),
        "tier2": tier2.toJson(),
        "tier3": tier3.toJson(),
      };
}

class ConfigLimitsSetting {
  const ConfigLimitsSetting({
    this.id = '',
    this.tokenThreshold = 0,
    this.storageSize = 0,
    this.uploadSize = 0,
    this.items = 0,
    this.files = 0,
    this.backups = 0,
    this.devices = 0,
    this.trashDays = 0,
    this.protectedItems = 0,
    this.sharedMembers = 0,
    this.sharedVaults = 0,
    this.customVaults = 0,
    this.customCategories = 0,
    this.encryptedFiles = 0,
    this.breachScanner = false,
    this.passwordHealth = false,
    this.nfcKeycard = false,
    this.cipherTool = false,
    this.otpGenerator = false,
    this.prioritySupport = false,
  });

  final String id;
  final int tokenThreshold;
  final int storageSize;
  final int uploadSize;
  final int items;
  final int files;
  final int backups;
  final int devices;
  final int trashDays;
  final int protectedItems;
  final int sharedMembers;
  final int sharedVaults;
  final int customVaults;
  final int customCategories;
  final int encryptedFiles;
  final bool breachScanner;
  final bool passwordHealth;
  final bool nfcKeycard;
  final bool cipherTool;
  final bool otpGenerator;
  final bool prioritySupport;

  factory ConfigLimitsSetting.fromJson(Map<String, dynamic> json) =>
      ConfigLimitsSetting(
        id: json["id"],
        tokenThreshold: json["token_threshold"],
        storageSize: json["storage_size"],
        uploadSize: json["upload_size"],
        items: json["items"],
        files: json["files"],
        backups: json["backups"],
        devices: json["devices"],
        trashDays: json["trash_days"],
        protectedItems: json["protected_items"],
        sharedMembers: json["shared_members"],
        sharedVaults: json["shared_vaults"],
        customVaults: json["custom_vaults"],
        customCategories: json["custom_categories"],
        encryptedFiles: json["encrypted_files"],
        breachScanner: json["breach_scanner"],
        passwordHealth: json["password_health"],
        nfcKeycard: json["nfc_keycard"],
        cipherTool: json["cipher_tool"],
        otpGenerator: json["otp_generator"],
        prioritySupport: json["priority_support"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "token_threshold": tokenThreshold,
        "storage_size": storageSize,
        "upload_size": uploadSize,
        "items": items,
        "files": files,
        "backups": backups,
        "devices": devices,
        "trash_days": trashDays,
        "protected_items": protectedItems,
        "shared_members": sharedMembers,
        "shared_vaults": sharedVaults,
        "custom_vaults": customVaults,
        "custom_categories": customCategories,
        "encrypted_files": encryptedFiles,
        "breach_scanner": breachScanner,
        "password_health": passwordHealth,
        "nfc_keycard": nfcKeycard,
        "cipher_tool": cipherTool,
        "otp_generator": otpGenerator,
        "priority_support": prioritySupport,
      };
}
