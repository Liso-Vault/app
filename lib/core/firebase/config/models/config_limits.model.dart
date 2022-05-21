class ConfigLimits {
  const ConfigLimits({
    this.regular = const LimitConfig(),
    this.holder = const LimitConfig(),
    this.staker = const LimitConfig(),
    this.premium = const LimitConfig(),
  });

  final LimitConfig regular;
  final LimitConfig holder;
  final LimitConfig staker;
  final LimitConfig premium;

  factory ConfigLimits.fromJson(Map<String, dynamic> json) => ConfigLimits(
        regular: LimitConfig.fromJson(json["regular"]),
        holder: LimitConfig.fromJson(json["holder"]),
        staker: LimitConfig.fromJson(json["staker"]),
        premium: LimitConfig.fromJson(json["premium"]),
      );

  Map<String, dynamic> toJson() => {
        "regular": regular.toJson(),
        "holder": holder.toJson(),
        "staker": staker.toJson(),
        "premium": premium.toJson(),
      };
}

class LimitConfig {
  const LimitConfig({
    this.tokenThreshold = 0,
    this.storageSize = 0,
    this.uploadSize = 0,
    this.items = 0,
    this.files = 0,
    this.backups = 0,
    this.trashDays = 0,
    this.addVaults = false,
    this.protectedItems = 0,
    this.fileEncryption = false,
    this.customSyncProvider = false,
    this.syncProviders = const [],
  });

  final int tokenThreshold;
  final int storageSize;
  final int uploadSize;
  final int items;
  final int files;
  final int backups;
  final int trashDays;
  final bool addVaults;
  final int protectedItems;
  final bool fileEncryption;
  final bool customSyncProvider;
  final List<String> syncProviders;

  factory LimitConfig.fromJson(Map<String, dynamic> json) => LimitConfig(
        tokenThreshold: json["token_threshold"],
        storageSize: json["storage_size"],
        uploadSize: json["upload_size"],
        items: json["items"],
        files: json["files"],
        backups: json["backups"],
        trashDays: json["trash_days"],
        addVaults: json["add_vaults"],
        protectedItems: json["protected_items"],
        fileEncryption: json["file_encryption"],
        customSyncProvider: json["custom_sync_provider"],
        syncProviders: List<String>.from(json["sync_providers"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "token_threshold": tokenThreshold,
        "storage_size": storageSize,
        "upload_size": uploadSize,
        "items": items,
        "files": files,
        "backups": backups,
        "trash_days": trashDays,
        "add_vaults": addVaults,
        "protected_items": protectedItems,
        "file_encryption": fileEncryption,
        "custom_sync_provider": customSyncProvider,
        "sync_providers": List<dynamic>.from(syncProviders.map((x) => x)),
      };
}
