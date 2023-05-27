import 'package:app_core/license/model/license.model.dart';

class Status {
  const Status({
    // this.balance = 0,
    this.license = const License(),
  });

  // final int balance;
  final License license;

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        // balance: json["balance"],
        license: License.fromJson(json["license"]),
      );

  Map<String, dynamic> toJson() => {
        // "balance": balance,
        "license": license.toJson(),
      };
}
