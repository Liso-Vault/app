// USED FOR WINDOWS ONLY

import 'dart:convert';

import 'package:liso/core/firebase/config/models/config_app.model.dart';
import 'package:liso/core/firebase/config/models/config_general.model.dart';
import 'package:liso/core/firebase/config/models/config_limits.model.dart';
import 'package:liso/core/firebase/config/models/config_secrets.model.dart';
import 'package:liso/core/firebase/config/models/config_users.model.dart';
import 'package:liso/core/firebase/config/models/config_web3.model.dart';

class ConfigRoot {
  ConfigRoot({
    required this.conditions,
    required this.parameters,
    required this.parameterGroups,
    required this.etag,
    required this.version,
  });

  List<Condition> conditions;
  Parameters parameters;
  ParameterGroups parameterGroups;
  String etag;
  Version version;

  factory ConfigRoot.fromJson(Map<String, dynamic> json) => ConfigRoot(
        conditions: List<Condition>.from(
            json["conditions"].map((x) => Condition.fromJson(x))),
        parameters: Parameters.fromJson(json["parameters"]),
        parameterGroups: ParameterGroups.fromJson(json["parameterGroups"]),
        etag: json["etag"],
        version: Version.fromJson(json["version"]),
      );

  Map<String, dynamic> toJson() => {
        "conditions": List<dynamic>.from(conditions.map((x) => x.toJson())),
        "parameters": parameters.toJson(),
        "parameterGroups": parameterGroups.toJson(),
        "etag": etag,
        "version": version.toJson(),
      };
}

class Condition {
  Condition({
    required this.name,
    required this.expression,
    required this.tagColor,
  });

  String name;
  String expression;
  String tagColor;

  factory Condition.fromJson(Map<String, dynamic> json) => Condition(
        name: json["name"],
        expression: json["expression"],
        tagColor: json["tagColor"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "expression": expression,
        "tagColor": tagColor,
      };
}

class ParameterGroups {
  ParameterGroups({
    required this.templates,
  });

  Templates templates;

  factory ParameterGroups.fromJson(Map<String, dynamic> json) =>
      ParameterGroups(
        templates: Templates.fromJson(json["Templates"]),
      );

  Map<String, dynamic> toJson() => {
        "Templates": templates.toJson(),
      };
}

class Templates {
  Templates({
    required this.parameters,
  });

  Map<String, ConfigValue> parameters;

  factory Templates.fromJson(Map<String, dynamic> json) => Templates(
        parameters: Map.from(json["parameters"]).map((k, v) =>
            MapEntry<String, ConfigValue>(k, ConfigValue.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "parameters": Map.from(parameters)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class ConfigValue {
  ConfigValue({
    required this.defaultValue,
    required this.valueType,
  });

  DefaultValue defaultValue;
  String valueType;

  factory ConfigValue.fromJson(Map<String, dynamic> json) => ConfigValue(
        defaultValue: DefaultValue.fromJson(json["defaultValue"]),
        valueType: json["valueType"],
      );

  Map<String, dynamic> toJson() => {
        "defaultValue": defaultValue.toJson(),
        "valueType": valueType,
      };
}

class DefaultValue {
  DefaultValue({
    required this.value,
  });

  String value;

  factory DefaultValue.fromJson(Map<String, dynamic> json) => DefaultValue(
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
      };
}

class Parameters {
  Parameters({
    required this.generalConfig,
    required this.web3Config,
    required this.secretsConfig,
    required this.usersConfig,
    required this.limitsConfig,
    required this.appConfig,
  });

  ConfigGeneral generalConfig;
  ConfigWeb3 web3Config;
  ConfigSecrets secretsConfig;
  ConfigUsers usersConfig;
  ConfigLimits limitsConfig;
  ConfigApp appConfig;

  factory Parameters.fromJson(Map<String, dynamic> json) => Parameters(
        generalConfig: ConfigGeneral.fromJson(
          jsonDecode(
            ConfigValue.fromJson(json["general_config"]).defaultValue.value,
          ),
        ),
        web3Config: ConfigWeb3.fromJson(
          jsonDecode(
            ConfigValue.fromJson(json["web3_config"]).defaultValue.value,
          ),
        ),
        secretsConfig: ConfigSecrets.fromJson(
          jsonDecode(
            ConfigValue.fromJson(json["secrets_config"]).defaultValue.value,
          ),
        ),
        usersConfig: ConfigUsers.fromJson(
          jsonDecode(
            ConfigValue.fromJson(json["users_config"]).defaultValue.value,
          ),
        ),
        limitsConfig: ConfigLimits.fromJson(
          jsonDecode(
            ConfigValue.fromJson(json["limits_config"]).defaultValue.value,
          ),
        ),
        appConfig: ConfigApp.fromJson(
          jsonDecode(
            ConfigValue.fromJson(json["app_config"]).defaultValue.value,
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "general_config": generalConfig.toJson(),
        "web3_config": web3Config.toJson(),
        "secrets_config": secretsConfig.toJson(),
        "users_config": usersConfig.toJson(),
        "limits_config": limitsConfig.toJson(),
        "app_config": appConfig.toJson(),
      };
}

class Version {
  Version({
    required this.versionNumber,
    required this.updateOrigin,
    required this.updateType,
    required this.updateUser,
    required this.updateTime,
  });

  String versionNumber;
  String updateOrigin;
  String updateType;
  UpdateUser updateUser;
  String updateTime;

  factory Version.fromJson(Map<String, dynamic> json) => Version(
        versionNumber: json["versionNumber"],
        updateOrigin: json["updateOrigin"],
        updateType: json["updateType"],
        updateUser: UpdateUser.fromJson(json["updateUser"]),
        updateTime: json["updateTime"],
      );

  Map<String, dynamic> toJson() => {
        "versionNumber": versionNumber,
        "updateOrigin": updateOrigin,
        "updateType": updateType,
        "updateUser": updateUser.toJson(),
        "updateTime": updateTime,
      };
}

class UpdateUser {
  UpdateUser({
    required this.email,
  });

  String email;

  factory UpdateUser.fromJson(Map<String, dynamic> json) => UpdateUser(
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
      };
}
