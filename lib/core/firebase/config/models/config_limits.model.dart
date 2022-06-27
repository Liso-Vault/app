class ConfigLimits {
  const ConfigLimits({
    this.settings = const ConfigLimitsSettings(),
    this.free = const ConfigLimitsTier(),
    this.holder = const ConfigLimitsTier(),
    this.staker = const ConfigLimitsTier(),
    this.trial = const ConfigLimitsTier(),
    this.pro = const ConfigLimitsTier(),
  });

  final ConfigLimitsSettings settings;
  final ConfigLimitsTier free;
  final ConfigLimitsTier holder;
  final ConfigLimitsTier staker;
  final ConfigLimitsTier trial;
  final ConfigLimitsTier pro;

  factory ConfigLimits.fromJson(Map<String, dynamic> json) => ConfigLimits(
        settings: ConfigLimitsSettings.fromJson(json["settings"]),
        free: ConfigLimitsTier.fromJson(json["free"]),
        holder: ConfigLimitsTier.fromJson(json["holder"]),
        staker: ConfigLimitsTier.fromJson(json["staker"]),
        trial: ConfigLimitsTier.fromJson(json["trial"]),
        pro: ConfigLimitsTier.fromJson(json["pro"]),
      );

  Map<String, dynamic> toJson() => {
        "settings": settings.toJson(),
        "free": free.toJson(),
        "holder": holder.toJson(),
        "staker": staker.toJson(),
        "trial": trial.toJson(),
        "pro": pro.toJson(),
      };
}

class ConfigLimitsSettings {
  const ConfigLimitsSettings({
    this.trialDays = 30,
  });

  final int trialDays;

  factory ConfigLimitsSettings.fromJson(Map<String, dynamic> json) =>
      ConfigLimitsSettings(
        trialDays: json["trial_days"],
      );

  Map<String, dynamic> toJson() => {
        "trial_days": trialDays,
      };
}

class ConfigLimitsTier {
  const ConfigLimitsTier({
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

  factory ConfigLimitsTier.fromJson(Map<String, dynamic> json) =>
      ConfigLimitsTier(
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
