class ConfigUsers {
  const ConfigUsers({
    this.users = const [],
  });

  final List<ConfigUser> users;

  factory ConfigUsers.fromJson(Map<String, dynamic> json) => ConfigUsers(
        users: List<ConfigUser>.from(
            json["users"].map((x) => ConfigUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
      };
}

class ConfigUser {
  const ConfigUser({
    this.address = '',
    this.limits = '',
  });

  final String address;
  final String limits;

  factory ConfigUser.fromJson(Map<String, dynamic> json) => ConfigUser(
        address: json["address"],
        limits: json["limits"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "limits": limits,
      };
}
